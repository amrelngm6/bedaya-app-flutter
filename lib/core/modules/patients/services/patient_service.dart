// ignore_for_file: use_null_aware_elements
import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/auth/models/auth_models.dart';
import 'package:bedaya2/core/modules/patients/models/medical_condition_model.dart';
import 'package:bedaya2/core/modules/patients/models/medical_record_model.dart';
import 'package:bedaya2/core/modules/patients/models/patient_medication.dart';
import 'package:bedaya2/core/modules/patients/models/patient_medication_report.dart';
import 'package:dio/dio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Patient Service
// ─────────────────────────────────────────────────────────────────────────────
class PatientService extends BaseApiService {
  const PatientService(super.client);

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<NetworkResult<UserModel>> getPatientProfile() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.patientProfile,
    );
    return UserModel.fromJson(_dataOf(response.data!));
  });

  // ─── Update Picture ─────────────────────────────────────────────────────
  Future<NetworkResult<String>> updateProfilePicture(FormData formData) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.updateAvatar,
          data: formData,
        );
        return response.data!['data']['user']['avatar'] ??
            response.data as String;
      });

  // ─── Update Profile ─────────────────────────────────────────────────────
  Future<NetworkResult<UserModel>> updatePatientProfile(
    Map<String, dynamic> updatedData,
  ) =>
      execute(() async {
        final response = await dio.put<Map<String, dynamic>>(
          ApiEndpoints.updateProfile,
          data: updatedData,
        );
        return UserModel.fromJson(_dataOf(response.data!));
      });

  
  // ─── Delete account  ──────────────────────────────────────────────────────
  Future<NetworkResult<void>> deleteAccount() => execute(() async {
    await dio.delete<void>(ApiEndpoints.deleteAccount);
  });

  // ─── Medical Records ──────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<MedicalRecordApiModel>>>
  getMedicalRecords({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? type,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.patientMedicalRecords,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (type != null) 'type': type,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['medical_records'],
      MedicalRecordApiModel.fromJson,
    );
  });

  // ─── Medications ──────────────────────────────────────────────────────────

  Future<NetworkResult<List<PatientMedication>>> getMedications({
    bool? activeOnly,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.patientMedications,
      queryParameters: {if (activeOnly != null) 'active_only': activeOnly},
    );
    final raw = response.data?['data'] as List<dynamic>? ?? [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PatientMedication.fromJson)
        .toList();
  });

  Future<NetworkResult<PatientMedication>> getMedicationById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.patientMedicationById(id),
        );
        return PatientMedication.fromJson(_dataOf(response.data!));
      });

  // ─── Reports ──────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<PatientMedicalReport>>> getReports({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? status,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.patientReports,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['reports'],
      PatientMedicalReport.fromJson,
    );
  });

  Future<NetworkResult<PatientMedicalReport>> getReportById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.patientReportById(id),
        );
        return PatientMedicalReport.fromJson(_dataOf(response.data!));
      });

  // ─── Appointments ─────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<Map<String, dynamic>>>>
  getPatientAppointments({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? status,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.patientAppointments,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['appointments'],
      (json) => json,
    );
  });

  // ─── Medical Profile (Conditions) ─────────────────────────────────────────

  Future<NetworkResult<List<MedicalProfileCondition>>> getMedicalConditions() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.medicalProfileConditions,
        );
        final data = _dataOf(response.data!);
        final rawList =
            (data['conditions'] ?? data['data'] ?? data) as List<dynamic>? ??
            [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(MedicalProfileCondition.fromJson)
            .toList();
      });

  Future<NetworkResult<MedicalProfileCondition>> getMedicalConditionById(
    int id,
  ) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.medicalProfileConditionById(id),
    );
    return MedicalProfileCondition.fromJson(_dataOf(response.data!));
  });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
