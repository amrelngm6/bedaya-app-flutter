import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/medication/models/medication_model.dart';

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onTap;
  final Function(String)? onMarkTaken;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTap,
    this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    final nextReminder = _getNextReminder();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: medication.prescribedByDoctor
                    ? AppColors.primaryTeal.withValues(alpha: 0.3)
                    : AppColors.greyOutline,
                width: medication.prescribedByDoctor ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        medication.type.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Medication name and type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.name,
                            style: AppStyles.h3.copyWith(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueBackground,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  medication.type.displayName.tr(),
                                  style: AppStyles.bodySmall.copyWith(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (medication.dosage != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  medication.dosage!,
                                  style: AppStyles.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Prescribed badge
                    if (medication.prescribedByDoctor)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.greyOutline.withValues(alpha: 0.3),
                ),

                const SizedBox(height: 12),

                // Frequency and next reminder
                Row(
                  children: [
                    // Frequency
                    if (medication.frequency != null) ...[
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        medication.frequency!.tr(),
                        style: AppStyles.bodySmall,
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Next reminder
                    if (nextReminder != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${'Next'.tr()}: ${nextReminder.time.hour.toString().padLeft(2, '0')}:${nextReminder.time.minute.toString().padLeft(2, '0')}',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                // Doctor info
                if (medication.prescribedByDoctor &&
                    medication.doctorName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        medication.doctorName!,
                        style: AppStyles.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],

                // Reminders display
                if (medication.reminderTimes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: medication.reminderTimes.map((reminder) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: reminder.taken
                              ? AppColors.onlineGreen.withValues(alpha: 0.1)
                              : AppColors.greyOutline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: reminder.taken
                                ? AppColors.onlineGreen
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (reminder.taken)
                              Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.onlineGreen,
                              )
                            else
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                              style: AppStyles.bodySmall.copyWith(
                                color: reminder.taken
                                    ? AppColors.onlineGreen
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Instructions preview
                if (medication.instructions != null &&
                    medication.instructions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.darkTeal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            medication.instructions!,
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.darkTeal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ReminderTime? _getNextReminder() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    ReminderTime? nextReminder;
    int minDiff = 24 * 60; // 24 hours in minutes

    for (var reminder in medication.reminderTimes) {
      if (!reminder.taken) {
        final reminderMinutes = reminder.time.hour * 60 + reminder.time.minute;
        int diff;

        if (reminderMinutes >= currentMinutes) {
          diff = reminderMinutes - currentMinutes;
        } else {
          // Next day
          diff = (24 * 60) - currentMinutes + reminderMinutes;
        }

        if (diff < minDiff) {
          minDiff = diff;
          nextReminder = reminder;
        }
      }
    }

    return nextReminder;
  }
}
