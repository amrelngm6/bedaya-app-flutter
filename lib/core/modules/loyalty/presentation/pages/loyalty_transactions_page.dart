import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/loyalty/models/loyalty_model.dart';

class LoyaltyTransactionsPage extends StatefulWidget {
  const LoyaltyTransactionsPage({super.key});

  @override
  State<LoyaltyTransactionsPage> createState() =>
      _LoyaltyTransactionsPageState();
}

class _LoyaltyTransactionsPageState extends State<LoyaltyTransactionsPage> {
  final List<LoyaltyTransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sl.analytics.trackScreen('LoyaltyTransactionsPage');
    _scrollController.addListener(_onScroll);
    _fetchTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl.loyalty.getTransactions(page: 1);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _transactions
            ..clear()
            ..addAll(data.data);
          _currentPage = 1;
          _hasMore = data.hasNextPage;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final result = await sl.loyalty.getTransactions(page: _currentPage + 1);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _transactions.addAll(data.data);
          _currentPage++;
          _hasMore = data.hasNextPage;
          _isLoadingMore = false;
        });
      case Failure():
        setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'loyalty_transactions_history'.tr(),
          style: AppStyles.h2.copyWith(fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 64, color: AppColors.greyOutline),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 80),
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.greyOutline,
          ),
          const SizedBox(height: 16),
          Center(child: Text('no_transactions_yet'.tr(), style: AppStyles.h3)),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _transactions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildTransactionTile(_transactions[index]);
      },
    );
  }

  Widget _buildTransactionTile(LoyaltyTransactionModel transaction) {
    final color = transaction.isEarn
        ? AppColors.onlineGreen
        : AppColors.errorRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isEarn
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description?.isNotEmpty == true
                      ? transaction.description!
                      : (transaction.isEarn
                            ? 'loyalty_points_earned'.tr()
                            : 'loyalty_points_redeemed'.tr()),
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (transaction.formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(transaction.formattedDate, style: AppStyles.bodySmall),
                ],
              ],
            ),
          ),
          Text(
            '${transaction.isEarn ? '+' : '-'}${transaction.points}',
            style: AppStyles.h3.copyWith(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
