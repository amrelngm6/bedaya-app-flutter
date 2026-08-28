// ignore_for_file: use_null_aware_elements
import 'package:bedaya2/core/modules/bookings/models/appointment_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Booking API models
// ─────────────────────────────────────────────────────────────────────────────

/// Matches the Laravel booking resource.
class CreateBookingRequest {
  const CreateBookingRequest({
    required this.doctorId,
    required this.slotId,
    required this.bookingType,
    this.notes,
    this.bookingDate,
    this.title,
    this.startTime,
    this.cost,
    this.serviceId,
  });

  final int doctorId;
  final int slotId;
  final String? bookingDate;
  final String? title;
  final String? startTime;
  final int? serviceId;
  final double? cost;

  /// 'in_person' | 'online'
  final String bookingType;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'slot_id': slotId,
    'booking_type': bookingType,
    if (cost != null) 'cost': cost,
    if (serviceId != null) 'service_id': serviceId,
    if (bookingDate != null && bookingDate!.isNotEmpty)
      'scheduled_date': bookingDate!.trim(),

    if (title != null && title!.isNotEmpty) 'title': title!.trim(),

    if (startTime != null && startTime!.isNotEmpty)
      'start_time': startTime!.trim(),

    // 'start_time': '00:00',
    if (notes != null && notes!.isNotEmpty) 'notes': notes!.trim(),
  };
}

class RescheduleRequest {
  const RescheduleRequest({
    required this.bookingId,
    required this.newSlotId,
    this.reason,
  });

  final int bookingId;
  final int newSlotId;
  final String? reason;

  Map<String, dynamic> toJson() => {
    'slot_id': newSlotId,
    if (reason != null && reason!.isNotEmpty) 'reason': reason!.trim(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Service
// ─────────────────────────────────────────────────────────────────────────────

class BookingService extends BaseApiService {
  const BookingService(super.client);

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<NetworkResult<AppointmentModel>> createBooking(
    CreateBookingRequest request,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.bookings,
      data: request.toJson(),
    );
    AppointmentModel appointmentModel = AppointmentModel.fromJson(
      _dataOf(response.data!['data'] as Map<String, dynamic>),
    );
    showTakenConfirmation(appointmentModel);
    return appointmentModel;
  });

  /// Shows an immediate local notification confirming the medication was taken.
  Future<void> showTakenConfirmation(AppointmentModel booking) async {
    final body = booking.doctorName.isNotEmpty
        ? 'Appointment with Dr. ${booking.doctorName} · ${booking.appointmentDate} ${booking.appointmentTime}'
        : 'Appointment with Dr. ${booking.doctorName}';

    final FlutterLocalNotificationsPlugin local_ =
        FlutterLocalNotificationsPlugin();

    const kChannelId_ = 'booking_confirmations';
    const kChannelName_ = 'Booking Confirmations';
    const kChannelDesc_ = 'Notifications for confirmed bookings';

    await local_.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Appointment Confirmed'.tr(),
      body: '$body ✓',
      payload: 'appointment_confirmed:${booking.id}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelId_,
          kChannelName_,
          channelDescription: kChannelDesc_,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<AppointmentModel>>> getMyBookings({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? status, // 'pending' | 'confirmed' | 'completed' | 'cancelled'
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.bookings,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'sort_order': 'desc',
        if (status != null) 'status_id': status,
      },
    );

    late PaginatedResponse<AppointmentModel> res;
    try {
      res = PaginatedResponse.fromJson(
        response.data!,
        response.data!['data']['bookings'],
        AppointmentModel.fromJson,
      );
    } catch (e) {
      res = PaginatedResponse<AppointmentModel>(
        data: [],
        currentPage: 1,
        lastPage: 1,
        perPage: AppConfig.defaultPageSize,
        total: 0,
      );
    }
    return res;
  });

  // ─── Upcoming ─────────────────────────────────────────────────────────────
  Future<NetworkResult<List<AppointmentModel>>> getUpcomingBookings() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.bookings,
          queryParameters: {'status_id': '4'},
        );
        final rawList =
            response.data!['data']['bookings'] as List<dynamic>? ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(AppointmentModel.fromJson)
            .toList();
      });

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<NetworkResult<AppointmentModel>> getBookingById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.bookingById(id),
        );
        return AppointmentModel.fromJson(_dataOf(response.data!));
      });

  // ─── Cancel ───────────────────────────────────────────────────────────────

  Future<NetworkResult<AppointmentModel>> cancelBooking(
    int id, {
    String? reason,
  }) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.cancelBooking(id),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason.trim()},
    );
    return AppointmentModel.fromJson(_dataOf(response.data!));
  });

  // ─── Reschedule ───────────────────────────────────────────────────────────

  Future<NetworkResult<AppointmentModel>> rescheduleBooking(
    RescheduleRequest request,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.rescheduleBooking(request.bookingId),
      data: request.toJson(),
    );
    return AppointmentModel.fromJson(_dataOf(response.data!));
  });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
