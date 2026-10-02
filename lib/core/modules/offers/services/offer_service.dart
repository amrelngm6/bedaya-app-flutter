import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/offers/models/offer_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Offer Service
// ─────────────────────────────────────────────────────────────────────────────
class OfferService extends BaseApiService {
  const OfferService(super.client);

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<OfferApiModel>>> getOffers({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.offers,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final body = response.data!;
    final dataNode = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final rawList =
        (dataNode['offers'] ?? dataNode['data'] ?? []) as List<dynamic>;
    final pagination = dataNode['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: rawList
          .whereType<Map<String, dynamic>>()
          .map(OfferApiModel.fromJson)
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

  Future<NetworkResult<OfferApiModel>> getOfferById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.offerById(id),
        );
        return OfferApiModel.fromJson(_dataOf(response.data!));
      });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
