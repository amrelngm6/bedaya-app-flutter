import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/services/helper_service.dart';
import 'package:bedaya2/presentation/widgets/empty_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';

/// Launches Paymob's Flutter SDK to pay the supplied [invoice].
///
/// [setting] should contain at least `paymob_public_key`. A
/// `paymob_client_secret` can be provided directly; otherwise the app
/// calls the backend intention endpoint via [PaymobApiService].
Future<void> payWithPaymob(
  BuildContext context,
  Invoice invoice,
  Map<String, dynamic> setting,
) async {
  if (invoice.totalAmount == null || invoice.totalAmount! <= 0) {
    showSuccessDialog(
      context,
      'Error'.tr(),
      'invoice total amount is not defined yet'.tr(),
      back,
    );
    return;
  }

  final publicKey =
      setting['paymob_public_key']?.toString() ??
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFMU1UWXNJbTVoYldVaU9pSXhOemcwTVRVNE1UYzJMamN5TkRReU15SjkuUmtDU1pFMTQ1dTJNajYxZDNhNWVjT1haLXhiSVZUYUIwWjdBaEUtVjVJNEhvQ0c3d3NiTzBHWl9VR1lGdGpEamdBS0hZdjFNR096Zzh2Vk9xQWE4UXc=';
  var clientSecret = setting['paymob_client_secret']?.toString();

  if (publicKey.isEmpty) {
    showSuccessDialog(
      context,
      'Error'.tr(),
      'Paymob public key is not configured.'.tr(),
      back,
    );
    return;
  }

  if (clientSecret == null || clientSecret.isEmpty) {
    final result = await sl.paymob.createClientSecret(invoice);
    switch (result) {
      case Success(:final data):
        clientSecret = data;
      case Failure(:final exception):
        showSuccessDialog(
          // ignore: use_build_context_synchronously
          context,
          'Error'.tr(),
          exception.message,
          back,
        );
        return;
    }
  }

  final service = PaymobService();
  final result = await service.payWithPaymob(
    publicKey: publicKey,
    clientSecret: clientSecret,
    customization: PaymobCustomization(
      appName: setting['app_name']?.toString() ?? 'Bedaya',
      buttonBackgroundColor: Colors.teal,
      buttonTextColor: Colors.white,
      showSaveCard: true,
      saveCardDefault: false,
      showTransactionResult: true,
    ),
  );

  if (result.isSuccessful) {
    await processPaymobPayment(context, result, invoice);
    offPage(
      EmptyData(
        title: 'Payment Successful'.tr(),
        text:
            "${'Thanks for payment'.tr()}, ${'We will contact you ASAP.'.tr()}",
      ),
    );
  } else if (result.isFailure) {
    showSuccessDialog(
      // ignore: use_build_context_synchronously
      context,
      'Error'.tr(),
      result.errorMessage ?? 'Payment failed.'.tr(),
      back,
    );
  }
}

/// Sends the successful Paymob transaction details to the backend so the
/// invoice can be marked as paid.
Future<void> processPaymobPayment(
  BuildContext context,
  PaymobPaymentResult result,
  Invoice invoice,
) async {
  final transactionDetails = result.transactionDetails ?? {};

  final data = {
    "payment_method": 'paymob',
    "transaction": {
      "payment_method": 'paymob',
      "status": "paid",
      "subscription_id": 0,
      "amount": invoice.totalAmount,
      "field": {
        "payment_method": 'paymob',
        "status": "paid",
        "transaction_id": transactionDetails['id'],
        "order_id": transactionDetails['order_id'],
        "amount": invoice.totalAmount,
      },
    },
    "invoice": {
      "payment_method": 'paymob',
      "status": "paid",
      "total_amount": invoice.totalAmount,
      "subtotal": invoice.subtotal,
      "notes": "Invoice #${invoice.code}",
      "discount_amount": invoice.discountAmount ?? 0,
      "items": [
        {
          "item_id": invoice.invoiceId,
          "item_type": 'Invoice',
          "subtotal": invoice.subtotal,
          "discount_amount": invoice.discountAmount ?? 0,
          "total_amount": invoice.totalAmount,
          "status": 'paid',
        },
      ],
    },
  };

  final response = await sl.invoices.addInvoiceTransaction(data);

  if (response is! Map<String, dynamic>) {
    showSuccessDialog(
      // ignore: use_build_context_synchronously
      context,
      'Error'.tr(),
      'Unexpected response from server.'.tr(),
      back,
    );
    return;
  }

  final res = response as Map<String, dynamic>;
  if (res.containsKey('result') && res['result'] != true) {
    showSuccessDialog(
      // ignore: use_build_context_synchronously
      context,
      'Error'.tr(),
      res['result'].toString(),
      back,
    );
  } else {
    back();
    offPage(
      EmptyData(
        title: 'Payment Successful'.tr(),
        text:
            "${'Thanks for payment'.tr()}, ${'We will contact you ASAP.'.tr()}",
      ),
    );
  }
}
