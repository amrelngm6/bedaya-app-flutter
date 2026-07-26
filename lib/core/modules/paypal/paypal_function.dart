import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/modules/paypal/paypal_payment.dart';
import 'package:bedaya2/core/services/helper_service.dart';
import 'package:bedaya2/presentation/widgets/empty_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> payWithPayPal(
  BuildContext context,
  Invoice invoice,
  Map<String, dynamic> setting,
) async {
  // ignore: use_build_context_synchronously
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true,
        note: 'Invoice #${invoice.code}',
        clientId: setting['paypal_api_key'].toString(),
        secretKey: setting['paypal_api_secret'].toString(),
        cancelURL: '${AppConfig.baseUrl}paypal_payment/canceled',
        returnURL: '${AppConfig.baseUrl}paypal_payment/rejected',
        transactions: [
          {
            "amount": {
              "total": invoice.totalAmount,
              "currency": setting['currency'].toString(),
              "details": {
                "subtotal": invoice.subtotal,
                "shipping": '0',
                "shipping_discount": 0,
              },
            },
            "description": "Invoice #${invoice.code}",
            "item_list": {
              "items": [
                {
                  "name": "Invoice #${invoice.code}",
                  "quantity": 1,
                  "price": invoice.totalAmount,
                  "currency": setting['currency'].toString(),
                },
              ],
            },
          },
        ],
        onSuccess: (Map params) async {
          await processPayPalTripPayment(context, params, invoice);
          // back();
          offPage(
            EmptyData(
              title: 'Payment Successful'.tr(),
              text:
                  "${'Thanks for payment'.tr()}, ${'We will contact you ASAP.'.tr()}",
            ),
          );
        },
        onError: (error) {
          showSuccessDialog(
            context,
            'Error'.tr(),
            error['message'].toString(),
            back,
          );
        },
        onCancel: () {},
      ),
    ),
  );
}

Future<void> processPayPalTripPayment(
  BuildContext context,
  Map order,
  Invoice invoice,
) async {
  // Safely extract PayPal response data
  Map<String, dynamic> payerInfo = {};
  if (order['data'] != null && order['data']['payer'] != null) {
    payerInfo = order['data']['payer']['payer_info'] ?? {};
  }

  Map<String, dynamic> data = {
    "payment_method": 'paypal',
    "transaction": {
      "payment_method": 'paypal',
      "status": "paid",
      "subscription_id": 0,
      "amount": invoice.totalAmount,
      "field": {
        "payment_method": 'paypal',
        "status": "paid",
        "order_id": order['data']?['id'] ?? '',
        "payer_first_name": payerInfo['first_name'] ?? '',
        "payer_last_name": payerInfo['last_name'] ?? '',
        "payer_country_code": payerInfo['country_code'] ?? '',
        "payer_payer_id": payerInfo['payer_id'] ?? '',
        "payer_email": payerInfo['email'] ?? '',
        "amount": invoice.totalAmount,
      },
    },
    "invoice": {
      "payment_method": 'paypal',
      "status": "paid",
      "total_amount": invoice.totalAmount,
      "subtotal": invoice.subtotal,
      "notes": "Invoice  #${invoice.code}",
      "discount_amount": 0,
      "items": [
        {
          "item_id": invoice.invoiceId,
          "item_type": 'Invoice',
          "subtotal": invoice.subtotal,
          "discount_amount": 0,
          "total_amount": invoice.totalAmount,
          "status": 'paid',
        },
      ],
    },
  };

  final result = await sl.invoices.addInvoiceTransaction(data);

  if (result is! Map<String, dynamic>) {
    showSuccessDialog(
      // ignore: use_build_context_synchronously
      context,
      'Error'.tr(),
      'Unexpected response from server.'.tr(),
      back,
    );
    return;
  }

  if (result is Map<String, dynamic>) {
    final res = result as Map<String, dynamic>;
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
