import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/offers/models/offer_model.dart';

class OfferDetailsPage extends StatefulWidget {
  const OfferDetailsPage({super.key, required this.offer});

  final OfferApiModel offer;

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  late OfferApiModel _offer;

  @override
  void initState() {
    super.initState();
    _offer = widget.offer;
    sl.analytics.trackScreen('OfferDetailsPage - ${_offer.title}');
    _loadOfferDetails();
  }

  Future<void> _loadOfferDetails() async {
    final result = await sl.offers.getOfferById(widget.offer.id);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => _offer = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = context.locale == const Locale('ar')
        ? (_offer.arabicTitle?.isNotEmpty == true
              ? _offer.arabicTitle!
              : _offer.title)
        : _offer.title;
    final description = context.locale == const Locale('ar')
        ? (_offer.arabicDescription?.isNotEmpty == true
              ? _offer.arabicDescription
              : _offer.description)
        : _offer.description;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primaryTeal,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _offer.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.lightBlueBackground,
                  child: const Icon(
                    Icons.local_offer,
                    size: 80,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.h1.copyWith(fontSize: 24)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.stars_rounded,
                        label: 'offer_points_value'.tr(
                          args: ['${_offer.points}'],
                        ),
                        color: AppColors.ratingGold,
                      ),
                      const SizedBox(width: 12),
                      if (_offer.expiryDate != null)
                        _buildInfoChip(
                          icon: Icons.event_outlined,
                          label: _offer.isExpired
                              ? 'offer_expired'.tr()
                              : 'offer_expires_on'.tr(
                                  args: [_offer.formattedExpiryDate],
                                ),
                          color: _offer.isExpired
                              ? AppColors.errorRed
                              : AppColors.darkTeal,
                        ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Description'.tr(), style: AppStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
