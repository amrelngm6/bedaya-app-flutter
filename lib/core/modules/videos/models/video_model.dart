/// Recognized video sources returned by the API.
enum VideoSourceType { youtube, upload }

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
    this.videoType,
    this.embedUrl,
    this.watchUrl,
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
  final String? videoType;
  final String? embedUrl;
  final String? watchUrl;

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
    videoType: json['video_type'] as String?,
    embedUrl: json['embed_url'] as String?,
    watchUrl: json['watch_url'] as String?,
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
    videoType: videoType,
    embedUrl: embedUrl,
    watchUrl: watchUrl,
  );

  /// The URL that best represents where the video should be played from.
  String get playbackUrl => embedUrl ?? watchUrl ?? videoUrl;

  /// Whether this video should be rendered through a YouTube player.
  bool get isYoutube =>
      videoType == 'youtube' || VideoUrlUtils.isYoutubeUrl(playbackUrl);

  /// Extracts the YouTube video id from the available urls, if any.
  String? get youtubeVideoId => VideoUrlUtils.extractYoutubeId(playbackUrl);
}

/// Helpers to classify and parse video urls independent of the model,
/// so any raw url (e.g. from other modules) can be handled the same way.
class VideoUrlUtils {
  const VideoUrlUtils._();

  static final RegExp _youtubeIdPattern = RegExp(
    r'(?:youtube(?:-nocookie)?\.com\/(?:.*[?&]v=|(?:embed|v|shorts|live)\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
  );

  static bool isYoutubeUrl(String url) =>
      url.contains('youtube.com') || url.contains('youtu.be');

  static String? extractYoutubeId(String url) {
    final match = _youtubeIdPattern.firstMatch(url);
    return match?.group(1);
  }
}
