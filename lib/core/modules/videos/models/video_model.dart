class VideoApiModel {
  const VideoApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    this.durationSeconds,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final bool isLikedByMe;
  final int? durationSeconds;
  final String? publishedAt;

  factory VideoApiModel.fromJson(Map<String, dynamic> json) => VideoApiModel(
    id: json['video_id'] as int,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    videoUrl: json['video_url'] as String? ?? '',
    thumbnailUrl: json['thumbnail'] as String?,
    likesCount: json['likes_count'] as int? ?? 0,
    viewsCount: json['views_count'] as int? ?? 0,
    commentsCount: json['comments_count'] as int? ?? 0,
    isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
    durationSeconds: json['duration_seconds'] as int?,
    publishedAt: json['published_at'] as String?,
  );

  VideoApiModel copyWith({bool? isLikedByMe, int? likesCount}) => VideoApiModel(
    id: id,
    title: title,
    description: description,
    videoUrl: videoUrl,
    thumbnailUrl: thumbnailUrl,
    likesCount: likesCount ?? this.likesCount,
    viewsCount: viewsCount,
    commentsCount: commentsCount,
    isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    durationSeconds: durationSeconds,
    publishedAt: publishedAt,
  );
}
