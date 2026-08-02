import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
// import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:dio/dio.dart';
import 'package:bedaya2/core/network/network_result.dart';

/// Backend-facing service for Paymob-related operations.
///
/// The actual Paymob SDK UI is launched from [paymob_function.dart]; this
/// service only exists to fetch a [clientSecret] from the backend so the
/// SDK can initialise the checkout session securely.
class PaymobApiService extends BaseApiService {
  const PaymobApiService(super.client);

  /// Creates a payment intention on the backend and returns the
  /// Paymob client secret required to launch the SDK.
  Future<NetworkResult<String>> createClientSecret(
    Invoice invoice,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      "https://accept.paymob.com/v1/intention",
      data: {
        'invoice_id': invoice.invoiceId,
        'amount': invoice.totalAmount,
        'currency': 'EGP',
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Token ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFMU1UWXNJbTVoYldVaU9pSXhOemcwTVRVNE1UYzJMamN5TkRReU15SjkuUmtDU1pFMTQ1dTJNajYxZDNhNWVjT1haLXhiSVZUYUIwWjdBaEUtVjVJNEhvQ0c3d3NiTzBHWl9VR1lGdGpEamdBS0hZdjFNR096Zzh2Vk9xQWE4UXc=',
        },
      ),
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    final clientSecret = data?['client_secret'] as String?;

    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Paymob client secret not returned by server.');
    }

    return clientSecret;
  });
}
