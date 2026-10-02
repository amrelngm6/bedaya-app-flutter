import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/offers/models/offer_model.dart';
import 'package:bedaya2/core/modules/offers/presentation/widgets/offer_card.dart';
import 'package:bedaya2/core/modules/loyalty/models/loyalty_model.dart';
import 'package:bedaya2/core/modules/loyalty/presentation/widgets/loyalty_points_card.dart';

class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  final List<OfferApiModel> _offers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  LoyaltyBalanceModel? _balance;
  bool _isLoadingBalance = true;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sl.analytics.trackScreen('OffersListPage');
    _scrollController.addListener(_onScroll);
    _fetchBalance();
    _fetchOffers();
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

  Future<void> _fetchBalance() async {
    setState(() => _isLoadingBalance = true);
    final result = await sl.loyalty.getPointsBalance();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _balance = data;
          _isLoadingBalance = false;
        });
      case Failure():
        setState(() => _isLoadingBalance = false);
    }
  }

  Future<void> _fetchOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await sl.offers.getOffers(page: 1);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _offers
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

    final result = await sl.offers.getOffers(page: _currentPage + 1);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _offers.addAll(data.data);
          _currentPage++;
          _hasMore = data.hasNextPage;
          _isLoadingMore = false;
        });
      case Failure():
        setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_fetchBalance(), _fetchOffers()]);
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
        title: Text('Offers'.tr(), style: AppStyles.h2.copyWith(fontSize: 20)),
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _offers.isEmpty) {
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
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _fetchOffers,
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        LoyaltyPointsCard(balance: _balance, isLoading: _isLoadingBalance),
        const SizedBox(height: 24),
        Text(
          'available_offers'.tr(),
          style: AppStyles.h2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_offers.isEmpty)
          _buildEmptyState()
        else ...[
          for (final offer in _offers) OfferCard(offer: offer),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 72,
            color: AppColors.greyOutline,
          ),
          const SizedBox(height: 16),
          Text('no_offers_available'.tr(), style: AppStyles.h3),
        ],
      ),
    );
  }
}
