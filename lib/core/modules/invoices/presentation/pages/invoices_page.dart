import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/invoices/models/invoice.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

import 'invoice_details_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final List<Invoice> _invoices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchInvoices(page: _currentPage + 1);
      }
    });
  }

  Future<void> _fetchInvoices({int page = 1}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (page == 1) {
        _invoices.clear();
      }
    });

    final result = await sl.invoices.getMyInvoices(page: page);

    if (mounted) {
      setState(() {
        _isLoading = false;
        switch (result) {
          case Success(:final data):
            final items = data.data;
            if (items.isEmpty) {
              _hasMore = false;
            } else {
              _invoices.addAll(items);
              _currentPage = page;
              _hasMore = data.currentPage != data.lastPage;
            }
          case Failure(:final exception):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(exception.message)));
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    _hasMore = true;
    await _fetchInvoices(page: 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Invoices'.tr(), style: AppStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryTeal),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryTeal,
        child: _isLoading && _invoices.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal),
              )
            : _invoices.isEmpty
            ? Stack(
                children: [
                  ListView(), // for pull to refresh
                  Center(
                    child: Text(
                      'No invoices found'.tr(),
                      style: AppStyles.bodyLarge,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _invoices.length + (_hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == _invoices.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    );
                  }
                  final invoice = _invoices[index];
                  return _buildInvoiceCard(invoice);
                },
              ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = invoice.status?.toLowerCase() == 'paid'
        ? AppColors.onlineGreen
        : AppColors.errorRed;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InvoiceDetailsPage(invoiceId: invoice.invoiceId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyOutline.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primaryTeal,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.code ?? '#${invoice.invoiceId}',
                    style: AppStyles.h3.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  if (invoice.date != null)
                    Text(
                      invoice.date!,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EGP ${invoice.totalAmount ?? 0}',
                  style: AppStyles.h3.copyWith(
                    color: AppColors.primaryTeal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (invoice.status ?? 'Unknown').tr(),
                    style: AppStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
