import '../../../network/api_endpoints.dart';
import '../../../network/base_api_service.dart';
import '../../../network/network_result.dart';
import '../../../network/paginated_response.dart';
import '../../medication/models/medical_report_model.dart';
import '../models/fertility_test_model.dart';

/// Wraps all mobile-facing medical-report API calls:
///
///   GET  /mobile/medical-reports/tests
///   GET  /mobile/medical-reports
///   GET  /mobile/medical-reports/{id}
///   POST /mobile/medical-reports
///   GET  /mobile/medical-reports/statistics
class MedicalReportService extends BaseApiService {
  const MedicalReportService(super.client);

  // ─── Reference data ───────────────────────────────────────────────────────

  /// Fetches all active fertility reference tests, optionally filtered by
  /// [category].  Returns a list of [FertilityTestCategory] objects
  /// (each one containing the category label + its list of tests), plus the
  /// raw `analysis_types` map from the backend.
  Future<NetworkResult<MedicalTestsResponse>> getTests({String? category}) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.medicalReportsTests,
          queryParameters: {
            if (category != null && category.isNotEmpty) 'category': category,
          },
        );

        final data = response.data!['data'] as Map<String, dynamic>;

        final rawCategories = data['categories'] as List<dynamic>? ?? [];
        final categories = rawCategories
            .whereType<Map<String, dynamic>>()
            .map(FertilityTestCategory.fromJson)
            .toList();

        final analysisTypes =
            (data['analysis_types'] as Map<String, dynamic>?) ?? {};

        return MedicalTestsResponse(
          categories: categories,
          analysisTypes: analysisTypes,
        );
      });

  // ─── Report list ──────────────────────────────────────────────────────────

  /// Returns a paginated list of the authenticated client's reports.
  Future<NetworkResult<PaginatedResponse<MedicalReport>>> getReports({
    int page = 1,
    int perPage = 20,
    String? analysisType,
    String? status,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.medicalReports,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'analysis_type': ?analysisType,
        'status': ?status,
      },
    );

    final data = response.data!['data'] as Map<String, dynamic>;
    final rawList = data['reports'] as List<dynamic>? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    final reports = rawList
        .whereType<Map<String, dynamic>>()
        .map(MedicalReport.fromJson)
        .toList();

    return PaginatedResponse<MedicalReport>(
      data: reports,
      currentPage: (pagination['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
      perPage: (pagination['per_page'] as num?)?.toInt() ?? perPage,
      total: (pagination['total'] as num?)?.toInt() ?? reports.length,
    );
  });

  // ─── Single report ────────────────────────────────────────────────────────

  Future<NetworkResult<MedicalReport>> getReport(int id) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.medicalReportById(id),
    );
    return MedicalReport.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  // ─── Submit report ────────────────────────────────────────────────────────

  /// Submits a new report and returns the created [MedicalReport] with
  /// the AI analysis already populated by the backend.
  Future<NetworkResult<MedicalReport>> submitReport({
    required String analysisType,
    required Map<String, dynamic> parameters,
    String? notes,
  }) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.medicalReports,
      data: {
        'analysis_type': analysisType,
        'parameters': parameters,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return MedicalReport.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  // ─── Statistics ───────────────────────────────────────────────────────────

  Future<NetworkResult<MedicalReportStatistics>> getStatistics() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.medicalReportsStatistics,
        );
        return MedicalReportStatistics.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });
}

// ─── Response / DTO helpers ──────────────────────────────────────────────────

class MedicalTestsResponse {
  final List<FertilityTestCategory> categories;

  /// Raw `analysis_types` map from the backend, e.g.
  /// `{"hormone": "Hormone Panel", "thyroid": "Thyroid Function", …}`.
  final Map<String, dynamic> analysisTypes;

  const MedicalTestsResponse({
    required this.categories,
    required this.analysisTypes,
  });

  /// Flat list of every [FertilityTest] across all categories.
  List<FertilityTest> get allTests =>
      categories.expand((c) => c.tests).toList();

  /// Tests for a specific [category] key.
  List<FertilityTest> testsForCategory(String category) => categories
      .where((c) => c.category == category)
      .expand((c) => c.tests)
      .toList();
}

class MedicalReportStatistics {
  final int total;
  final int completed;
  final int reviewed;
  final Map<String, int> byType;

  const MedicalReportStatistics({
    required this.total,
    required this.completed,
    required this.reviewed,
    required this.byType,
  });

  factory MedicalReportStatistics.fromJson(Map<String, dynamic> json) {
    final rawByType = json['by_type'] as Map<String, dynamic>? ?? {};
    return MedicalReportStatistics(
      total: (json['total'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      reviewed: (json['reviewed'] as num?)?.toInt() ?? 0,
      byType: rawByType.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}
