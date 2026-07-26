class SlideModel {
  final String id;
  final String title;
  final String arTitle;
  final String description;
  final String arDescription;
  final String? imageUrl;
  final String? action;
  final bool isActive;

  SlideModel({
    required this.id,
    required this.title,
    required this.arTitle,
    required this.description,
    required this.arDescription,
    this.imageUrl,
    this.action,
    this.isActive = true,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: json['id'].toString(),
      title: (json['title']) as String,
      arTitle: (json['arabic_title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      arDescription: (json['arabic_description'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] ?? true) as bool,
      action: json['action'] as String?,
    );
  }
}
