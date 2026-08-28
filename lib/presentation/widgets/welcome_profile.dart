import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/patients/presentation/pages/patient_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/styles.dart';

class WelcomeProfile extends StatelessWidget {
  final PatientModel? patient;
  const WelcomeProfile({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D7885), // Custom teal from image
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: context.locale == const Locale('en') ? 0 : null,
            left: context.locale == const Locale('ar') ? 0 : null,
            height: 100,
            child: Image.asset('assets/vector.png', fit: BoxFit.cover),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    _navigateToProfile(context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'welcome_back'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        "${patient?.fullName}",
                        style: AppStyles.h1.copyWith(color: Colors.white),
                      ),
                      Text(
                        'nice_to_see_you_again'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    if (patient != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientProfilePage(patient: patient!),
        ),
      );
    }
  }
}
