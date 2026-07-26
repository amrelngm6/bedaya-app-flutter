/// UI-level enum for analysis types.
/// Each value exposes an [apiKey] that matches the backend string constant.
enum AnalysisType {
  hormone('hormone'),
  ovarianReserve('ovarian_reserve'),
  thyroid('thyroid'),
  semen('semen'),
  ultrasound('ultrasound'),
  metabolic('metabolic'),
  blood('blood'),
  infection('infection'),
  immunology('immunology'),
  embryology('embryology'),
  pregnancy('pregnancy'),
  genetic('genetic'),
  vitamin('vitamin'),
  androgen('androgen');

  const AnalysisType(this.apiKey);

  /// The snake_case key sent to / received from the backend.
  final String apiKey;

  /// Resolve from a backend [apiKey] string; returns `null` if unknown.
  static AnalysisType? fromApiKey(String key) {
    for (final v in values) {
      if (v.apiKey == key) return v;
    }
    return null;
  }

  String get displayName {
    switch (this) {
      case AnalysisType.hormone:
        return 'Hormone Panel';
      case AnalysisType.ovarianReserve:
        return 'Ovarian Reserve';
      case AnalysisType.thyroid:
        return 'Thyroid Function';
      case AnalysisType.semen:
        return 'Semen Analysis';
      case AnalysisType.ultrasound:
        return 'Ultrasound Scan';
      case AnalysisType.metabolic:
        return 'Metabolic Panel';
      case AnalysisType.blood:
        return 'Blood Count';
      case AnalysisType.infection:
        return 'Infection Screening';
      case AnalysisType.immunology:
        return 'Immunology Test';
      case AnalysisType.embryology:
        return 'Embryology Report';
      case AnalysisType.pregnancy:
        return 'Pregnancy Test';
      case AnalysisType.genetic:
        return 'Genetic Testing';
      case AnalysisType.vitamin:
        return 'Vitamin Levels';
      case AnalysisType.androgen:
        return 'Androgen Profile';
    }
  }
}

/// A medical report returned by the backend `MedicalReportResource`.
///
/// Maps 1-to-1 to the Laravel resource fields:
/// id, report_number, analysis_type, analysis_type_label, report_date,
/// parameters, ai_analysis, recommendation, status, status_label,
/// status_color, notes, is_from_app, created_at, updated_at.
class MedicalReport {
  final int id;
  final String? reportNumber;
  final String analysisType; // raw backend key, e.g. "hormone"
  final String? analysisTypeLabel;
  final DateTime? reportDate;
  final Map<String, dynamic> parameters;

  /// Per-field server-computed analysis results.
  /// Keyed by field_key (or test_name if no field_key).
  /// Each entry: { field_key, test_name, value, unit, status, status_label,
  ///              normal_min, normal_max, normal_range_text, critical_low, critical_high }
  final Map<String, dynamic> fieldResults;

  final String? aiAnalysis;
  final String? recommendation;
  final String status;
  final String? statusLabel;
  final String? statusColor;
  final String? notes;
  final bool isFromApp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicalReport({
    required this.id,
    this.reportNumber,
    required this.analysisType,
    this.analysisTypeLabel,
    this.reportDate,
    required this.parameters,
    this.fieldResults = const {},
    this.aiAnalysis,
    this.recommendation,
    this.status = 'pending',
    this.statusLabel,
    this.statusColor,
    this.notes,
    this.isFromApp = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Build from the backend `MedicalReportResource` JSON.
  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reportNumber: json['report_number'] as String?,
      analysisType: json['analysis_type'] as String? ?? '',
      analysisTypeLabel: json['analysis_type_label'] as String?,
      reportDate: json['report_date'] != null
          ? DateTime.tryParse(json['report_date'] as String)
          : null,
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
      fieldResults: (json['field_results'] as Map<String, dynamic>?) ?? {},
      aiAnalysis: json['ai_analysis'] as String?,
      recommendation: json['recommendation'] as String?,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      statusColor: json['status_color'] as String?,
      notes: json['notes'] as String?,
      isFromApp: json['is_from_app'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Serialise to the format expected by `POST /mobile/medical-reports`.
  Map<String, dynamic> toSubmitJson({String? notes}) {
    return {
      'analysis_type': analysisType,
      'parameters': parameters,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
  }

  MedicalReport copyWith({
    int? id,
    String? reportNumber,
    String? analysisType,
    String? analysisTypeLabel,
    DateTime? reportDate,
    Map<String, dynamic>? parameters,
    String? aiAnalysis,
    String? recommendation,
    String? status,
    String? statusLabel,
    String? statusColor,
    String? notes,
    bool? isFromApp,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? fieldResults,
  }) {
    return MedicalReport(
      id: id ?? this.id,
      reportNumber: reportNumber ?? this.reportNumber,
      analysisType: analysisType ?? this.analysisType,
      analysisTypeLabel: analysisTypeLabel ?? this.analysisTypeLabel,
      reportDate: reportDate ?? this.reportDate,
      parameters: parameters ?? this.parameters,
      fieldResults: fieldResults ?? this.fieldResults,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      recommendation: recommendation ?? this.recommendation,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColor: statusColor ?? this.statusColor,
      notes: notes ?? this.notes,
      isFromApp: isFromApp ?? this.isFromApp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Resolves [analysisType] to the [AnalysisType] enum, or `null`.
  AnalysisType? get analysisTypeEnum => AnalysisType.fromApiKey(analysisType);

  /// Display name: prefers [analysisTypeLabel] from the backend, falls back
  /// to the enum's built-in display name, and finally the raw key.
  String get analysisTypeDisplayName =>
      analysisTypeLabel ?? analysisTypeEnum?.displayName ?? analysisType;

  /// The date to display in the UI (prefers [reportDate], falls back to [createdAt]).
  DateTime get displayDate => reportDate ?? createdAt ?? DateTime.now();
}
