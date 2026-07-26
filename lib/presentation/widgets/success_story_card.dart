import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

class SuccessStoryCard extends StatelessWidget {
  final SuccessStoryApiModel story;

  const SuccessStoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with patient info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.1),
                  AppColors.lightBlueBackground,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.patientName,
                        style: AppStyles.h3.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (story.serviceUsed != null) ...[
                            Icon(
                              Icons.medical_services,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              story.serviceUsed!,
                              style: AppStyles.bodySmall,
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (story.year != null) ...[
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              story.year.toString(),
                              style: AppStyles.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.onlineGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: AppColors.onlineGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Story content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.greyOutline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '"${story.story}"',
                    style: AppStyles.bodyLarge.copyWith(
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Rating row
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < story.rating.round() ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.ratingGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
