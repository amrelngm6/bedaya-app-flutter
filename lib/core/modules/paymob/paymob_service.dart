import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/modules/paymob/paymob_payment.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
// import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/services/helper_service.dart';
import 'package:dio/dio.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  Future<NetworkResult<String>> getPaymentUrl(int invoiceId) =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.getPaymentUrl(invoiceId),
        );
        final data = response.data;
        final paymentUrl = data?['payment_url'] as String?;

        if (paymentUrl == null || paymentUrl.isEmpty) {
          throw Exception('Payment URL not returned by server.');
        }

        return paymentUrl;
      });

  Future<void> payWithPaymobWebview(
    BuildContext context,
    Invoice invoice,
    Map<String, dynamic> setting,
  ) async {
    final paymentUrlResult = await getPaymentUrl(invoice.invoiceId);
    switch (paymentUrlResult) {
      case Success(:final data):
        final paymentUrl = data;
        if (paymentUrl.isEmpty) {
          showSuccessDialog(
            context,
            'Error'.tr(),
            'Payment URL is empty.'.tr(),
            back,
          );
          return;
        }

        // Open the payment URL in a webview
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymobCheckoutView(
              onSuccess: (data) {
                print('Payment successful: $data');
                Navigator.pop(context, data);
              },
              onError: (error) {
                print('Payment error: $error');
                Navigator.pop(context);
                showSuccessDialog(
                  context,
                  'Error'.tr(),
                  error.toString(),
                  back,
                );
              },
              onCancel: () {
                print('Payment cancelled by user.');
                Navigator.pop(context);
                showSuccessDialog(
                  context,
                  'Error'.tr(),
                  'Payment failed.'.tr(),
                  back,
                );
              },
              transactions: [
                {
                  "amount": invoice.totalAmount,
                  "currency": setting['currency']?.toString() ?? 'USD',
                },
              ],
              clientId: setting['paymob_client_id']?.toString() ?? '',
              secretKey: setting['paymob_client_secret']?.toString() ?? '',
              returnURL: setting['paymob_return_url']?.toString() ?? '',
              cancelURL: setting['paymob_cancel_url']?.toString() ?? '',
              invoiceId: invoice.invoiceId,
            ),
          ),
        );
      case Failure(:final exception):
        showSuccessDialog(context, 'Error'.tr(), exception.message, back);
    }
  }
}
