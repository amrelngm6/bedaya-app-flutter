import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:bedaya2/core/modules/videos/models/video_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/modules/ai/presentation/widgets/ai_banner.dart';
// import 'package:bedaya2/core/modules/doctors/presentation/widgets/doctors_slider.dart';
import 'package:bedaya2/core/modules/medication/presentation/widgets/pill_reminder.dart';
import 'package:bedaya2/core/modules/services/presentation/widgets/service_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/presentation/widgets/side_menu.dart';
import 'package:bedaya2/presentation/widgets/welcome_profile.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/appointment_card.dart';
import 'package:bedaya2/presentation/widgets/location_card.dart';
import 'package:bedaya2/core/modules/videos/presentation/widgets/videos_section.dart';
import 'package:bedaya2/core/di/service_locator.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  List<HospitalServiceApiModel> servicesList = [];
  late PatientModel myProfile;

  Future<void> _fetchServices() async {
    final result = await sl.hospitalServices.getServices();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => servicesList = data.data);
    }
  }

  Future<void> _fetchProfile() async {
    final result = await sl.auth.getMyProfile();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        myProfile = PatientModel.fromJson(data.toJson());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchVideos();
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(), // Hide default leading
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Logo placeholder
                Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://bedayahospitals.com/stream?image=/uploads/img/logo.webp',
                          ), // Placeholder for logo
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bedaya Hospital".tr(),
                          style: AppStyles.h3.copyWith(fontSize: 16),
                        ),
                        Text(
                          "Cleopatra Group".tr(),
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
      endDrawer: SideMenu(patient: myProfile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeProfile(patient: myProfile),
            const SizedBox(height: 30),

            // Pill Reminder Card
            const PillReminder(),
            const SizedBox(height: 20),

            const AppointmentCard(),
            const SizedBox(height: 30),

            // const DoctorsSlider(),
            VideosSection(
              videosPostersList: _videos.map((v) => v.thumbnailUrl!).toList(),
            ),
            const SizedBox(height: 30),

            Text("Discover Services".tr(), style: AppStyles.h2),
            const SizedBox(height: 16),
            if (servicesList.length > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: servicesList.map((service) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.only(right: 16),
                      child: ServiceCard(
                        label: service.category,
                        isSelected: false,
                        title: service.title,
                        description: service.description.length > 85
                            ? '${service.description.substring(0, 85)}...'
                            : service.description,
                        icon: Icons.medical_services,
                        service: service,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 30),

            const AITextBanner(),
            const SizedBox(height: 30),

            const LocationCard(),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  final List<VideoApiModel> _videos = [];

  Future<void> _fetchVideos() async {
    final result = await sl.videos.getVideos(page: 1);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _videos.addAll(data.data);
        });
      case Failure(:final exception):
        setState(() {
          exception.message;
        });
    }
  }
}
