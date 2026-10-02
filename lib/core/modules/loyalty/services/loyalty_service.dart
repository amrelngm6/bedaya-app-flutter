import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';
import 'package:bedaya2/core/modules/loyalty/models/loyalty_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loyalty Service
// ─────────────────────────────────────────────────────────────────────────────
class LoyaltyService extends BaseApiService {
  const LoyaltyService(super.client);

  // ─── Points balance ─────────────────────────────────────────────────────

  Future<NetworkResult<LoyaltyBalanceModel>> getPointsBalance() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.loyaltyPoints,
        );
        return LoyaltyBalanceModel.fromJson(_dataOf(response.data!));
      });

  // ─── Transactions history ───────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<LoyaltyTransactionModel>>>
  getTransactions({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.loyaltyTransactions,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final body = response.data!;
    final dataNode = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
    final rawList =
        (dataNode['transactions'] ?? dataNode['data'] ?? []) as List<dynamic>;
    final pagination = dataNode['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse(
      data: rawList
          .whereType<Map<String, dynamic>>()
          .map(LoyaltyTransactionModel.fromJson)
          .toList(),
      currentPage: pagination['current_page'] as int? ?? page,
      lastPage: pagination['last_page'] as int? ?? 1,
      perPage: pagination['per_page'] as int? ?? perPage,
      total: pagination['total'] as int? ?? rawList.length,
      from: pagination['from'] as int?,
      to: pagination['to'] as int?,
    );
  });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
