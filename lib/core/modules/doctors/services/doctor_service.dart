// ignore_for_file: use_null_aware_elements
import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_category.dart';
import 'package:bedaya2/core/modules/doctors/models/available_slot.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_review.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Service
// ─────────────────────────────────────────────────────────────────────────────
class DoctorService extends BaseApiService {
  const DoctorService(super.client);

  // ─── Doctors list ─────────────────────────────────────────────────────────
  Future<NetworkResult<PaginatedResponse<DoctorApiModel>>> getDoctors({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? categoryId,
    String? search,
    String? sortBy, // 'rating' | 'experience' | 'fee'
  }) => execute(() async {
    final isLoggedIn = sl.storage.isLoggedIn;
    final response = await dio.get<Map<String, dynamic>>(
      isLoggedIn ? ApiEndpoints.doctors : ApiEndpoints.guestDoctors,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryId != null) 'specialty': categoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sortBy != null) 'sort_by': sortBy,
      },
    );

    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['doctors'],
      DoctorApiModel.fromJson,
    );
  });

  // ─── Single doctor ────────────────────────────────────────────────────────

  Future<NetworkResult<DoctorApiModel>> getDoctorById(int id) =>
      execute(() async {
        final isLoggedIn = sl.storage.isLoggedIn;
        final response = await dio.get<Map<String, dynamic>>(
          isLoggedIn
              ? ApiEndpoints.doctorById(id)
              : ApiEndpoints.guestDoctorById(id),
        );
        return DoctorApiModel.fromJson(_dataOf(response.data!));
      });

  // ─── Categories ───────────────────────────────────────────────────────────

  Future<NetworkResult<List<DoctorCategory>>> getCategories() => execute(
    () async {
      final isLoggedIn = sl.storage.isLoggedIn;
      final response = await dio.get<Map<String, dynamic>>(
        isLoggedIn
            ? ApiEndpoints.doctorCategories
            : ApiEndpoints.guestDoctorCategories,
      );
      final raw = response.data?['data']['categories'] as List<dynamic>? ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(DoctorCategory.fromJson)
          .toList();
    },
  );

  // ─── Availability ─────────────────────────────────────────────────────────

  /// Returns available time slots for [doctorId] on a specific [date].
  /// [date] format: 'YYYY-MM-DD'
  Future<NetworkResult<List<AvailabilitySlot>>> getAvailability({
    required int doctorId,
    required String date,
    String? bookingType, // 'in_person' | 'online'
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctorAvailability(doctorId, date),
      queryParameters: {
        'date': date,
        if (bookingType != null) 'booking_type': bookingType,
      },
    );
    final raw = response.data?['data']['slots'] as List<dynamic>? ?? [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => AvailabilitySlot.fromJson(json, date))
        .toList();
  });

  // ─── Working hours ─────────────────────────────────────────────────
  Future<NetworkResult<List<AvailabilitySlot>>> getWorkingHours({
    required int doctorId,
    required String date,
    String? bookingType, // 'in_person' | 'online'
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctorWorkingHours(doctorId),
      queryParameters: {
        'date': date,
        if (bookingType != null) 'booking_type': bookingType,
      },
    );
    final raw = response.data?['schedule'] as List<dynamic>? ?? [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => AvailabilitySlot.fromJson(json, ''))
        .toList();
  });

  // ─── Available slots ──────────────────────────────────────────────────────

  Future<NetworkResult<List<AvailabilitySlot>>> getAvailableSlots({
    required int doctorId,
    required String date,
    String? bookingType, // 'in_person' | 'online'
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.slotsForDay(doctorId, date),
      queryParameters: {
        'date': date,
        if (bookingType != null) 'booking_type': bookingType,
      },
    );
    final raw = response.data?['data']['slots'] as List<dynamic>? ?? [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => AvailabilitySlot.fromJson(json, date))
        .toList();
  });

  // ─── Reviews ──────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<DoctorReview>>> getReviews({
    required int doctorId,
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctorReviews(doctorId),
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['reviews'],
      DoctorReview.fromJson,
    );
  });

  // ─── Like / Unlike ────────────────────────────────────────────────────────
  Future<NetworkResult<Map<String, dynamic>>> toggleLike(int doctorId) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.likeDoctorById(doctorId),
        );
        return response.data!;
      });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
