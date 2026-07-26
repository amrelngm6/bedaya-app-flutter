import 'package:bedaya2/core/modules/ai/services/medical_report_service.dart';
import 'package:bedaya2/core/modules/medication/models/medical_report_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class MedicalReportState {
  const MedicalReportState();
}

final class MedicalReportInitial extends MedicalReportState {
  const MedicalReportInitial();
}

/// Loading the reference tests from the API.
final class MedicalReportTestsLoading extends MedicalReportState {
  const MedicalReportTestsLoading();
}

/// Tests loaded successfully; ready for the user to pick an analysis type.
final class MedicalReportReady extends MedicalReportState {
  final MedicalTestsResponse testsData;
  final List<MedicalReport> previousReports;
  final bool isLoadingReports;

  const MedicalReportReady({
    required this.testsData,
    required this.previousReports,
    this.isLoadingReports = false,
  });

  MedicalReportReady copyWith({
    MedicalTestsResponse? testsData,
    List<MedicalReport>? previousReports,
    bool? isLoadingReports,
  }) {
    return MedicalReportReady(
      testsData: testsData ?? this.testsData,
      previousReports: previousReports ?? this.previousReports,
      isLoadingReports: isLoadingReports ?? this.isLoadingReports,
    );
  }
}

/// A report is being submitted to the backend.
final class MedicalReportSubmitting extends MedicalReportState {
  const MedicalReportSubmitting();
}

/// A report was submitted and AI analysis is ready.
final class MedicalReportSubmitted extends MedicalReportState {
  final MedicalReport report;
  final MedicalTestsResponse testsData;
  final List<MedicalReport> previousReports;

  const MedicalReportSubmitted({
    required this.report,
    required this.testsData,
    required this.previousReports,
  });
}

/// An error occurred.
final class MedicalReportError extends MedicalReportState {
  final String message;
  final bool isTestsError;

  const MedicalReportError(this.message, {this.isTestsError = false});
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class MedicalReportCubit extends Cubit<MedicalReportState> {
  MedicalReportCubit() : super(const MedicalReportInitial());

  MedicalReportService get _service => sl.medicalReports;

  MedicalTestsResponse? _testsData;
  final List<MedicalReport> _previousReports = [];

  // ─── Load tests ───────────────────────────────────────────────────────────

  Future<void> loadTests() async {
    emit(const MedicalReportTestsLoading());

    final result = await _service.getTests();
    switch (result) {
      case Success(:final data):
        _testsData = data;
        emit(
          MedicalReportReady(
            testsData: data,
            previousReports: List.unmodifiable(_previousReports),
            isLoadingReports: true,
          ),
        );
        // Load previous reports in the background
        await _loadPreviousReports();

      case Failure(:final exception):
        emit(MedicalReportError(exception.message, isTestsError: true));
    }
  }

  // ─── Load previous reports ─────────────────────────────────────────────────

  Future<void> _loadPreviousReports() async {
    final result = await _service.getReports(perPage: 25);
    switch (result) {
      case Success(:final data):
        _previousReports
          ..clear()
          ..addAll(data.data);

      case Failure():
        // Non-critical: silently ignore; the list will just be empty.
        break;
    }

    if (state is MedicalReportReady) {
      final current = state as MedicalReportReady;
      emit(
        current.copyWith(
          previousReports: List.unmodifiable(_previousReports),
          isLoadingReports: false,
        ),
      );
    }
  }

  // ─── Submit report ────────────────────────────────────────────────────────

  Future<void> submitReport({
    required AnalysisType analysisType,
    required Map<String, dynamic> parameters,
    String? notes,
  }) async {
    emit(const MedicalReportSubmitting());

    final result = await _service.submitReport(
      analysisType: analysisType.apiKey,
      parameters: parameters,
      notes: notes,
    );

    switch (result) {
      case Success(:final data):
        _previousReports.insert(0, data);
        emit(
          MedicalReportSubmitted(
            report: data,
            testsData: _testsData!,
            previousReports: List.unmodifiable(_previousReports),
          ),
        );

      case Failure(:final exception):
        // Restore the ready state so the user can retry
        emit(MedicalReportError(exception.message, isTestsError: false));
    }
  }

  // ─── Reset to ready ───────────────────────────────────────────────────────

  void resetToReady() {
    if (_testsData != null) {
      emit(
        MedicalReportReady(
          testsData: _testsData!,
          previousReports: List.unmodifiable(_previousReports),
        ),
      );
    } else {
      loadTests();
    }
  }

  // ─── Retry ────────────────────────────────────────────────────────────────

  void retry() => loadTests();
}
