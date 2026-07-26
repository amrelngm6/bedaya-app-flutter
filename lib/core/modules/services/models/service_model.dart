class ServiceModel {
  final String id;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String description;
  final String descriptionText;
  final String arabicDescription;
  final String arabicDescriptionText;
  final String heroImageUrl;
  final String? heroVideoUrl;
  final List<String> photoGallery;
  final List<VideoItem> videos;
  final List<SuccessStory> successStories;
  final List<ServiceFeature> features;
  final List<String> benefits;
  final String? price;
  final String? duration;
  final double rating;
  final int reviewsCount;

  ServiceModel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.description,
    required this.descriptionText,
    required this.arabicDescription,
    required this.arabicDescriptionText,
    required this.heroImageUrl,
    this.heroVideoUrl,
    required this.photoGallery,
    required this.videos,
    required this.successStories,
    required this.features,
    required this.benefits,
    this.price,
    this.duration,
    required this.rating,
    required this.reviewsCount,
  });
}

class VideoItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String duration;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
  });
}

class SuccessStory {
  final String id;
  final String patientName;
  final String patientAge;
  final String story;
  final String? photoUrl;
  final String? videoUrl;
  final String? videoThumbnail;
  final String date;

  SuccessStory({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.story,
    this.photoUrl,
    this.videoUrl,
    this.videoThumbnail,
    required this.date,
  });
}

class ServiceFeature {
  final String icon;
  final String title;
  final String description;

  ServiceFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
