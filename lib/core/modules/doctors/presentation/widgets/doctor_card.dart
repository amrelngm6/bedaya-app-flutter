import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/doctors/presentation/pages/doctor_details_page.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';

import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_appointment_page.dart';
import 'package:html2md/html2md.dart' as html2md;

// ignore: must_be_immutable
class DoctorCard extends StatelessWidget {
  DoctorApiModel doctor;

  DoctorCard({super.key, required this.doctor});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsPage(doctor: doctor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyOutline),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Online indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(doctor.imageUrl),
                    ),
                    if (doctor.isOnlineNow)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.onlineGreen,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.locale == Locale('ar')
                              ? doctor.arabicSpecialty
                              : doctor.specialty,
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.darkTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.locale == Locale('ar')
                            ? doctor.arabicName
                            : doctor.name,
                        style: AppStyles.h3.copyWith(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                        Text(
                          html2md.convert(doctor.bio!),
                          style: AppStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Experience & Rating/Book Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.darkTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'years_count'.tr(
                            args: [doctor.experienceYears.toString()],
                          ),
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text('experience'.tr(), style: AppStyles.bodySmall),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: doctor.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 14,
                          ignoreGestures: true,
                          itemPadding: EdgeInsets.zero,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: AppColors.ratingGold,
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${doctor.rating}",
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text('rating'.tr(), style: AppStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingAppointmentPage(preselectedDoctor: doctor),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF512DA8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'book'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
