class DoctorCategory {
  const DoctorCategory({
    required this.id,
    required this.name,
    required this.arabicName,
    this.icon,
  });

  final int id;
  final String name;
  final String? arabicName;
  final String? icon;

  factory DoctorCategory.fromJson(Map<String, dynamic> json) => DoctorCategory(
    id: json['category_id'] as int,
    name: json['name'] as String? ?? '',
    arabicName: json['arabic_name'] as String?,
    icon: json['icon'] as String?,
  );
}
