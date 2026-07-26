import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class ServiceFeatureCard extends StatelessWidget {
  final String feature;

  const ServiceFeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                feature,
                style: AppStyles.bodyMedium.copyWith(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
