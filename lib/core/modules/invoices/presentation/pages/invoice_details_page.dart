import 'package:bedaya2/core/modules/paymob/paymob_function.dart';
import 'package:bedaya2/core/modules/paypal/paypal_function.dart';
import 'package:bedaya2/core/services/helper_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

class InvoiceDetailsPage extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailsPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  Invoice? _invoice;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl.invoices.getInvoiceById(widget.invoiceId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        switch (result) {
          case Success(:final data):
            _invoice = data;
          case Failure(:final exception):
            _errorMessage = exception.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Invoice Details'.tr(), style: AppStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryTeal),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: AppStyles.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchInvoiceDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry'.tr()),
                  ),
                ],
              ),
            )
          : _invoice == null
          ? Center(child: Text('Invoice not found'.tr()))
          : _buildInvoiceContent(_invoice!),
    );
  }

  Widget _buildInvoiceContent(Invoice invoice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(invoice),
          const SizedBox(height: 24),
          if (invoice.items != null && invoice.items!.isNotEmpty) ...[
            Text('Items'.tr(), style: AppStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _buildItemsList(invoice.items!),
            const SizedBox(height: 24),
          ],
          _buildSummaryCard(invoice),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Invoice invoice) {
    final statusColor = invoice.status?.toLowerCase() == 'paid'
        ? AppColors.onlineGreen
        : AppColors.errorRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.code ?? '#${invoice.invoiceId}',
                style: AppStyles.h2.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (invoice.status ?? 'Unknown').tr(),
                  style: AppStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          if (invoice.date != null) _buildInfoRow('Date'.tr(), invoice.date!),
          if (invoice.paymentMethod != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Payment Method'.tr(), invoice.paymentMethod!),
          ],

          paymentMethods(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<InvoiceItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceName,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity} x EGP ${item.unitPrice}',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'EGP ${item.total}',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightBlueBackground, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal'.tr(), invoice.subtotal ?? 0),
          const SizedBox(height: 12),
          _buildSummaryRow('Discount'.tr(), invoice.discountAmount ?? 0),
          // const SizedBox(height: 12),
          // _buildSummaryRow('Tax'.tr(), invoice.taxAmount ?? 0),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total'.tr(),
                style: AppStyles.h3.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 18,
                ),
              ),
              Text(
                'EGP ${invoice.totalAmount ?? 0}',
                style: AppStyles.h3.copyWith(
                  color: AppColors.primaryTeal,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          'EGP $amount',
          style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget paymentMethods() {
    return (_invoice?.status == 'paid' || _invoice?.status == 'cancelled')
        ? Center()
        : Column(
            children: [
              const SizedBox(height: 20),

              paymentMethodRow(
                'Pay with PayPal',
                'PayPal',
                payWithPayPalAction,
                Icons.payment,
                Color.fromRGBO(0, 82, 255, 1),
              ),

              const SizedBox(height: 12),

              paymentMethodRow(
                'Pay with Paymob',
                'Paymob',
                payWithPaymobAction,
                Icons.credit_card,
                AppColors.primaryTeal,
              ),
            ],
          );
  }

  Widget paymentMethodRow(
    String title,
    String paymentMethodText,
    Function callback,
    IconData iconData,
    Color iconColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(iconData, size: 24),
              SizedBox(width: 10),
              Text(title.tr(), style: AppStyles.h3),
            ],
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: () => callback(),
            tooltip: paymentMethodText.tr(),
            icon: Icon(iconData, size: 24, color: Colors.red),
            color: iconColor,
          ),
        ),
      ],
    );
  }

  Future<void> payWithPayPalAction() async {
    if (_invoice?.totalAmount == 0) {
      showSuccessDialog(
        context,
        'Error'.tr(),
        'invoice total amount is not defined yet'.tr(),
        back,
      );
      return;
    }

    await payWithPayPal(context, _invoice!, {});
    // await loadInvoice();
  }

  Future<void> payWithPaymobAction() async {
    if (_invoice?.totalAmount == 0) {
      showSuccessDialog(
        context,
        'Error'.tr(),
        'invoice total amount is not defined yet'.tr(),
        back,
      );
      return;
    }

    await payWithPaymob(context, _invoice!, {});
  }
}
