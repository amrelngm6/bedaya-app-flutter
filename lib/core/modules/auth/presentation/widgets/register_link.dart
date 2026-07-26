import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget buildRegisterLink(BuildContext context, bool loading) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'auth_no_account'.tr(),
        style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      TextButton(
        onPressed: loading
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'auth_register'.tr(),
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
