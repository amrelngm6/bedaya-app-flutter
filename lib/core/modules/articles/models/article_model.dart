class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String authorName;
  final String authorRole;
  final String authorImageUrl;
  final String coverImageUrl;
  final DateTime publishedDate;
  final int readingTimeMinutes;
  final List<String> tags;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final List<String> relatedImages;

  final String publishedAt;
  final bool isLikedByMe;

  ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    required this.authorName,
    required this.authorRole,
    required this.authorImageUrl,
    required this.coverImageUrl,
    required this.publishedDate,
    required this.readingTimeMinutes,
    required this.tags,
    this.publishedAt = '',
    this.isLikedByMe = false,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.relatedImages = const [],
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article API model
// ─────────────────────────────────────────────────────────────────────────────

class ArticleApiModel {
  const ArticleApiModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    required this.authorName,
    required this.authorRole,
    required this.coverImageUrl,
    required this.publishedAt,
    required this.readingTimeMinutes,
    this.authorImageUrl,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isLikedByMe = false,
    this.tags = const [],
    this.relatedImages = const [],
    this.relatedArticles,
  });

  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final String authorName;
  final String authorRole;
  final String coverImageUrl;
  final String publishedAt;
  final int readingTimeMinutes;
  final String? authorImageUrl;
  final int viewsCount;
  final int likesCount;
  final bool isLikedByMe;
  final List<String> tags;
  final List<String> relatedImages;
  final List<ArticleApiModel>? relatedArticles;

  factory ArticleApiModel.fromJson(Map<String, dynamic> json) =>
      ArticleApiModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        content: json['content'] as String? ?? '',
        category: json['category']['name'] as String? ?? '',
        authorName: json['author_name'] as String? ?? '',
        authorRole: json['author_role'] as String? ?? '',
        coverImageUrl: json['cover_image_url'] as String? ?? '',
        publishedAt: json['published_date'] as String? ?? '',
        readingTimeMinutes: json['reading_time_minutes'] as int? ?? 1,
        authorImageUrl: json['author_image_url'] as String?,
        viewsCount: json['views_count'] as int? ?? 0,
        likesCount: json['likes_count'] as int? ?? 0,
        isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        relatedArticles: (json['related_articles'] as List<dynamic>?)
            ?.map((e) => ArticleApiModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  factory ArticleApiModel.fromArticleModel(ArticleModel json) =>
      ArticleApiModel(
        id: int.parse(json.id),
        title: json.title,
        subtitle: json.subtitle,
        content: json.content,
        category: json.category,
        authorName: json.authorName,
        authorRole: json.authorRole,
        coverImageUrl: json.coverImageUrl,
        publishedAt: json.publishedAt,
        readingTimeMinutes: json.readingTimeMinutes,
        authorImageUrl: json.authorImageUrl,
        viewsCount: json.viewsCount,
        likesCount: json.likesCount,
        isLikedByMe: json.isLikedByMe,
        tags: json.tags,
        relatedImages: json.relatedImages,
      );

  String get formattedDate {
    try {
      final now = DateTime.now();
      final difference = now.difference(DateTime.parse(publishedAt));

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else {
        final publishedDate = DateTime.parse(publishedAt);
        return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
      }
    } catch (e) {
      return publishedAt; // Fallback to raw string if parsing fails
    }
  }
}
