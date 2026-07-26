class PatientMedication {
  const PatientMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String dosage;
  final String frequency;
  final String startDate;
  final String? endDate;
  final String? prescribedBy;
  final String? notes;
  final bool isActive;

  factory PatientMedication.fromJson(Map<String, dynamic> json) =>
      PatientMedication(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        startDate: json['start_date'] as String? ?? '',
        endDate: json['end_date'] as String?,
        prescribedBy: json['prescribed_by'] as String?,
        notes: json['notes'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}
