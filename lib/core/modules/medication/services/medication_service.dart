import 'package:flutter/material.dart';

import '../models/medication_model.dart';
import '../../../network/api_endpoints.dart';
import '../../../network/base_api_service.dart';
import '../../../network/network_result.dart';

class MedicationService extends BaseApiService {
  const MedicationService(super.client);

  // ─── List all patient medications ────────────────────────────────────────

  Future<NetworkResult<List<MedicationModel>>> getMedications() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.patientMedications,
        );
        final rawList =
            response.data!['data']['medications'] as List<dynamic>? ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(MedicationModel.fromJson)
            .toList();
      });

  // ─── Active medications ───────────────────────────────────────────────────

  Future<NetworkResult<List<MedicationModel>>> getActiveMedications() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.activeMedications,
        );
        final rawList =
            response.data!['data']['medications'] as List<dynamic>? ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(MedicationModel.fromJson)
            .toList();
      });

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<NetworkResult<MedicationModel>> getMedicationById(Object id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.patientMedicationById(id),
        );
        return MedicationModel.fromJson(_dataOf(response.data!));
      });

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<NetworkResult<MedicationModel>> addMedication(
    MedicationModel medication,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.patientMedications,
      data: medication.toApiJson(),
    );
    return MedicationModel.fromJson(
      response.data!['data']['medication'] as Map<String, dynamic>,
    );
  });

  // ─── Update ───────────────────────────────────────────────────────────────

  Future<NetworkResult<MedicationModel>> updateMedication(
    MedicationModel medication,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.patientMedicationById(medication.id),
      data: medication.toApiJson(),
    );
    return MedicationModel.fromJson(
      response.data!['data']['medication'] as Map<String, dynamic>,
    );
  });

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<NetworkResult<void>> deleteMedication(Object id) => execute(() async {
    await dio.delete<void>(ApiEndpoints.patientMedicationById(id));
  });

  // ─── Take Medicine ─────────────────────────────────────────────────────────
  Future<NetworkResult<void>> takeMedication(
    MedicationModel medication,
    TimeOfDay scheduledTime,
    String type,
  ) => execute(() async {
    await dio.post<void>(
      ApiEndpoints.takeMedicationById(medication.id),
      data: {
        'type': type,
        'scheduled_time':
            '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
        'taken_at': DateTime.now().toIso8601String(),
      },
    );
  });

  // ─── Statistics ───────────────────────────────────────────────────────────

  Future<NetworkResult<Map<String, dynamic>>> getStatistics() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.medicationStatistics,
        );
        return _dataOf(response.data!);
      });

  // ─── Local helpers ────────────────────────────────────────────────────────

  /// Filters [medications] for doctor-prescribed entries.
  List<MedicationModel> getPrescribed(List<MedicationModel> medications) =>
      medications.where((m) => m.prescribedByDoctor).toList();

  /// Filters [medications] for user-added entries.
  List<MedicationModel> getUserAdded(List<MedicationModel> medications) =>
      medications.where((m) => !m.prescribedByDoctor).toList();

  /// Computes today's upcoming (not yet taken) reminders from [medications].
  List<Map<String, dynamic>> getTodaysReminders(
    List<MedicationModel> medications,
  ) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    final reminders = <Map<String, dynamic>>[];

    for (final medication in medications) {
      for (final reminder in medication.reminderTimes) {
        final reminderTime = reminder.time.hour * 60 + reminder.time.minute;
        if (reminderTime >= currentTime && !reminder.taken) {
          reminders.add({
            'medication': medication,
            'reminder': reminder,
            'timeInMinutes': reminderTime,
          });
        }
      }
    }

    reminders.sort(
      (a, b) =>
          (a['timeInMinutes'] as int).compareTo(b['timeInMinutes'] as int),
    );
    return reminders;
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
