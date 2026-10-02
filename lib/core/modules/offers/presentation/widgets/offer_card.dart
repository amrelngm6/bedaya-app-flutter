import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/offers/models/offer_model.dart';
import 'package:bedaya2/core/modules/offers/presentation/pages/offer_details_page.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer});

  final OfferApiModel offer;

  @override
  Widget build(BuildContext context) {
    final title = context.locale == const Locale('ar')
        ? (offer.arabicTitle?.isNotEmpty == true
              ? offer.arabicTitle!
              : offer.title)
        : offer.title;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsPage(offer: offer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyOutline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                offer.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 110,
                  color: AppColors.lightBlueBackground,
                  child: const Icon(
                    Icons.local_offer,
                    color: AppColors.primaryTeal,
                    size: 36,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.h3.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          size: 16,
                          color: AppColors.ratingGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'offer_points_value'.tr(args: ['${offer.points}']),
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTeal,
                          ),
                        ),
                      ],
                    ),
                    if (offer.expiryDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: offer.isExpired
                                ? AppColors.errorRed
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            offer.isExpired
                                ? 'offer_expired'.tr()
                                : 'offer_expires_on'.tr(
                                    args: [offer.formattedExpiryDate],
                                  ),
                            style: AppStyles.bodySmall.copyWith(
                              color: offer.isExpired
                                  ? AppColors.errorRed
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
