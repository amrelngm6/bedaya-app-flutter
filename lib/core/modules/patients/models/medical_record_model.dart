class MedicalRecordApiModel {
  const MedicalRecordApiModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.attachmentUrl,
    this.doctorName,
    this.notes,
  });

  final int id;

  /// 'lab_result' | 'imaging' | 'prescription' | 'procedure' | 'consultation'
  final String type;
  final String title;
  final String description;
  final String date;
  final String? attachmentUrl;
  final String? doctorName;
  final String? notes;

  factory MedicalRecordApiModel.fromJson(Map<String, dynamic> json) =>
      MedicalRecordApiModel(
        id: json['id'] as int,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        date: json['date'] as String? ?? '',
        attachmentUrl: json['attachment_url'] as String?,
        doctorName: json['doctor_name'] as String?,
        notes: json['notes'] as String?,
      );
}
