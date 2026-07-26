class SectionModel {
  final String id;
  final String title;
  final String key;
  final String description;
  final String? imageUrl;
  final bool isActive;

  SectionModel({
    required this.id,
    required this.title,
    required this.key,
    required this.description,
    this.imageUrl,
    this.isActive = true,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'].toString(),
      title: json['label'] as String,
      key: json['key'] as String,
      description: (json['description'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] ?? true) as bool,
    );
  }
}
