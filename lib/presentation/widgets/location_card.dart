import 'package:bedaya2/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('hospital_location'.tr(), style: AppStyles.h2),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300], // Placeholder for Map Image
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage(
                "https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              // Open map through URL launcher or navigate to map screen
              // Example: launch('https://maps.google.com/?q=Bedaya+Hospital');
              openMap();
              sl.analytics.trackTap(
                'location_open',
                screenName: 'HomePage - LocationCard',
              );
            },
            child: Stack(
              children: [
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'bedaya_hospital'.tr(),
                                style: AppStyles.h3.copyWith(fontSize: 16),
                              ),
                              Text(
                                'hospital_address'.tr(),
                                style: AppStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> openMap() async {
    // final Uri geoUrl = Uri.parse(
    //   "geo:30.044189,31.215623?q=30.044189,31.215623(Bedaya Hospital)",
    // );
    final Uri webUrl = Uri.parse(
      "https://www.google.com/maps/place/Bedaya+Hospital/@30.044189,31.215623,20z/data=!4m14!1m7!3m6!1s0x14584129f9f789d9:0xd5cd83df8da4bdd7!2sBedaya+Hospital!8m2!3d30.0441468!4d31.2156146!16s%2Fg%2F11bz0b_vcl!3m5!1s0x14584129f9f789d9:0xd5cd83df8da4bdd7!8m2!3d30.0441468!4d31.2156146!16s%2Fg%2F11bz0b_vcl?hl=en&entry=ttu&g_ep=EgoyMDI2MDYwMi4wIKXMDSoASAFQAw%3D%3D",
    );

    // if (await canLaunchUrl(geoUrl)) {
    //   await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    // } else
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.platformDefault);
    }
  }
}
