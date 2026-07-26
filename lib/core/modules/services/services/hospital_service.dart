import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hospital Service API models
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Hospital Service
// ─────────────────────────────────────────────────────────────────────────────

class HospitalService extends BaseApiService {
  const HospitalService(super.client);

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<NetworkResult<PaginatedResponse<HospitalServiceApiModel>>>
  getServices({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
    String? category,
    bool? highlightedOnly,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.services,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null && category.isNotEmpty) 'category': category,
        if (highlightedOnly == true) 'highlighted': true,
      },
    );
    return PaginatedResponse.fromJson(
      response.data!,
      response.data!['data']['services'],
      HospitalServiceApiModel.fromJson,
    );
  });

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<NetworkResult<HospitalServiceApiModel>> getServiceById(int id) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.serviceById(id),
        );
        return HospitalServiceApiModel.fromJson(_dataOf(response.data!));
      });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
}
