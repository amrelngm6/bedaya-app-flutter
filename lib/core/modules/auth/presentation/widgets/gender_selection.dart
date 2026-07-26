import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

// ─── Gender selector ──────────────────────────────────────────────────────────
class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, 
    required this.selected,
    required this.onChanged,
    required this.enabled,
  });
  final String selected;
  final void Function(String) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth_gender'.tr(),
          style: AppStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GenderChip(
              label: 'auth_male'.tr(),
              icon: Icons.male_rounded,
              value: 'male',
              selected: selected == 'male',
              enabled: enabled,
              onTap: () => onChanged('male'),
            ),
            const SizedBox(width: 12),
            GenderChip(
              label: 'auth_female'.tr(),
              icon: Icons.female_rounded,
              value: 'female',
              selected: selected == 'female',
              enabled: enabled,
              onTap: () => onChanged('female'),
            ),
          ],
        ),
      ],
    );
  }
}

class GenderChip extends StatelessWidget {
  const GenderChip({super.key, 
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryTeal.withValues(alpha: 0.1)
                : const Color(0xFFF0F7F8),
            border: Border.all(
              color: selected ? AppColors.primaryTeal : Colors.grey.shade300,
              width: selected ? 1.8 : 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primaryTeal : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppColors.primaryTeal
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
