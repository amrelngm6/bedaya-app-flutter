import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/styles.dart';

class ServicesBanner extends StatelessWidget {
  const ServicesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF512DA8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'discover_our_services'.tr(),
            style: AppStyles.h3.copyWith(color: Colors.white),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}
