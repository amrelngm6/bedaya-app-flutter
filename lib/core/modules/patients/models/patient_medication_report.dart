class PatientMedicalReport {
  const PatientMedicalReport({
    required this.id,
    required this.analysisType,
    required this.title,
    required this.status,
    required this.createdAt,
    this.resultSummary,
    this.fileUrl,
    this.doctorNote,
  });

  final int id;
  final String analysisType;
  final String title;

  /// 'pending' | 'completed' | 'requires_attention'
  final String status;
  final String createdAt;
  final String? resultSummary;
  final String? fileUrl;
  final String? doctorNote;

  factory PatientMedicalReport.fromJson(Map<String, dynamic> json) =>
      PatientMedicalReport(
        id: json['id'] as int,
        analysisType: json['analysis_type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String? ?? '',
        resultSummary: json['result_summary'] as String?,
        fileUrl: json['file_url'] as String?,
        doctorNote: json['doctor_note'] as String?,
      );
}
