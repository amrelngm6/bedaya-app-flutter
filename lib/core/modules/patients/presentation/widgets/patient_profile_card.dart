import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/patients/presentation/pages/patient_profile_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

class PatientProfileCard extends StatelessWidget {
  final PatientModel patient;

  const PatientProfileCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfilePage(patient: patient),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryTeal, AppColors.darkTeal],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: patient.avatar != null
                    ? NetworkImage(patient.avatar!)
                    : null,
                child: patient.avatar == null
                    ? Text(
                        patient.firstName[0].toUpperCase() +
                            patient.lastName[0].toUpperCase(),
                        style: AppStyles.h2.copyWith(
                          fontSize: 24,
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Patient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: AppStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${patient.age} ${'years'.tr()} • ${patient.gender!.tr()}",
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.bloodtype,
                        patient.medicalProfile?.bloodType ?? '',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.badge, patient.id.toString()),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow Icon
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
