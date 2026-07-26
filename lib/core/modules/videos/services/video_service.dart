import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/videos/models/video_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Video Service
// ─────────────────────────────────────────────────────────────────────────────

class VideoService extends BaseApiService {
  const VideoService(super.client);

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<VideoApiModel>>> getVideos({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? category,
    String? search,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      sl.storage.isLoggedIn ? ApiEndpoints.videos : ApiEndpoints.guestVideos,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final body = response.data!;
    final dataNode = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    // Support both `videos` and generic `data` list keys from server.
    final rawList =
        (dataNode['videos'] ?? dataNode['data'] ?? []) as List<dynamic>;
    final pagination = dataNode['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: rawList
          .whereType<Map<String, dynamic>>()
          .map(VideoApiModel.fromJson)
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? perPage,
      total: pagination['total'] as int? ?? rawList.length,
      from: pagination['from'] as int?,
      to: pagination['to'] as int?,
    );
  });

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<NetworkResult<VideoApiModel>> getVideoById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.videoById(id),
        );
        return VideoApiModel.fromJson(_dataOf(response.data!));
      });

  // ───  Add Comments  ────────────────────────────────────────────────────────

  Future<NetworkResult<Map<String, dynamic>>> addComment(
    int id,
    String comment,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.addVideoComment(id),
      data: {'comment': comment},
    );
    return response.data!['data'] ?? {};
  });

  Future<NetworkResult<List<Map<String, dynamic>>>> getComments(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.videoComments(id),
        );
        final rawList =
            response.data!['data']['comments'] as List<dynamic>? ?? [];
        return rawList.whereType<Map<String, dynamic>>().toList();
      });

  // ─── Like / Unlike ────────────────────────────────────────────────────────

  Future<NetworkResult<Map<String, dynamic>>> toggleLike(int id) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.likeVideo(id),
        );
        return response.data ?? {};
      });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
