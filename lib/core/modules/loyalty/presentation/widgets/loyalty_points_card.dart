import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/loyalty/models/loyalty_model.dart';
import 'package:bedaya2/core/modules/loyalty/presentation/pages/loyalty_transactions_page.dart';

/// Card that shows the patient's current loyalty points balance and a
/// shortcut to their transactions history.
class LoyaltyPointsCard extends StatelessWidget {
  const LoyaltyPointsCard({
    super.key,
    required this.balance,
    this.isLoading = false,
  });

  final LoyaltyBalanceModel? balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryTeal, AppColors.darkTeal],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'loyalty_points_balance'.tr(),
                style: AppStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.workspace_premium, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  '${balance?.pointsBalance ?? 0}',
                  style: AppStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoyaltyTransactionsPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text(
                'loyalty_view_transactions'.tr(),
                style: AppStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
