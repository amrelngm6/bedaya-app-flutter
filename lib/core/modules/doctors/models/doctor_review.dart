class DoctorReview {
  const DoctorReview({
    required this.id,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.patientAvatar,
  });

  final int id;
  final String patientName;
  final double rating;
  final String comment;
  final String createdAt;
  final String? patientAvatar;

  factory DoctorReview.fromJson(Map<String, dynamic> json) => DoctorReview(
    id: json['id'] as int,
    patientName: json['patient_name'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    comment: json['comment'] as String? ?? '',
    createdAt: json['created_at'] as String? ?? '',
    patientAvatar: json['patient_avatar'] as String?,
  );
}
