import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/articles/models/article_model.dart';

import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Article Service
// ─────────────────────────────────────────────────────────────────────────────

class ArticleService extends BaseApiService {
  const ArticleService(super.client);

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<ArticleApiModel>>> getArticles({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? category,
    String? search,
    String? tag,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      sl.storage.isLoggedIn
          ? ApiEndpoints.articles
          : ApiEndpoints.guestArticles,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['articles'],
      ArticleApiModel.fromJson,
    );
  });

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<NetworkResult<ArticleApiModel>> getArticleById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.articleById(id),
        );
        return ArticleApiModel.fromJson(_dataOf(response.data!));
      });

  // ─── Like / Unlike ────────────────────────────────────────────────────────

  Future<NetworkResult<Map<String, dynamic>>> toggleLike(int id) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.likeArticle(id),
        );
        return response.data!;
      });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
