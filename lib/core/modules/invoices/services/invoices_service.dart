import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/network/paginated_response.dart';

class InvoicesService extends BaseApiService {
  const InvoicesService(super.client);

  Future<NetworkResult<PaginatedResponse<Invoice>>> getMyInvoices({
    int page = 1,
    int perPage = AppConfig.defaultPageSize,
  }) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.invoices,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'sort_order': 'desc',
      },
    );

    late PaginatedResponse<Invoice> res;
    try {
      res = PaginatedResponse.fromJson(
        response.data!,
        response.data!['data']['invoices'] ?? [],
        (json) => Invoice.fromJson(json),
      );
    } catch (e) {
      res = PaginatedResponse<Invoice>(
        data: [],
        currentPage: 1,
        lastPage: 1,
        perPage: AppConfig.defaultPageSize,
        total: 0,
      );
    }
    return res;
  });

  Future<NetworkResult<Invoice>> getInvoiceById(int id) => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.invoiceById(id),
    );
    return Invoice.fromJson(_dataOf(response.data!));
  });

  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;

  Future<NetworkResult<Map<String, dynamic>>> addInvoiceTransaction(
    Map<String, dynamic> data,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.addInvoiceTransaction,
      data: data,
    );
    return response.data!;
  });
}
