import 'dart:async';

import 'package:bedaya2/core/models/slide_model.dart';
import 'package:bedaya2/core/modules/ai/presentation/widgets/smart_medical_analysis_card.dart';
import 'package:bedaya2/core/modules/articles/models/article_model.dart';
import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/models/section_model.dart';
import 'package:bedaya2/core/modules/bookings/models/appointment_model.dart';
import 'package:bedaya2/core/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:bedaya2/core/modules/notifications/services/notification_api_service.dart';
import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:bedaya2/core/modules/videos/models/video_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/modules/ai/presentation/widgets/ai_banner.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/appointment_card.dart';
import 'package:bedaya2/core/modules/articles/presentation/widgets/articles_widget.dart';
import 'package:bedaya2/core/modules/doctors/presentation/widgets/doctors_slider.dart';
import 'package:bedaya2/core/modules/medication/presentation/widgets/pill_reminder.dart';
import 'package:bedaya2/presentation/widgets/welcome_banner_slider.dart';
import 'package:bedaya2/presentation/widgets/welcome_profile.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/services/presentation/widgets/service_card.dart';
import 'package:bedaya2/core/modules/pregnancy_calculator/presentation/widgets/pregnancy_calculator_banner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
// import 'package:bedaya2/presentation/widgets/side_menu.dart';
import 'package:bedaya2/presentation/widgets/location_card.dart';
import 'package:bedaya2/core/modules/videos/presentation/widgets/videos_section.dart';
import 'package:bedaya2/core/modules/services/presentation/pages/services_list_page.dart';
import 'package:bedaya2/core/modules/articles/presentation/pages/articles_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HospitalServiceApiModel> servicesList = [];
  List<ArticleApiModel> articlesList = [];

  PatientModel? myProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.cyan[50],
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
                          style: AppStyles.h3.copyWith(
                            fontSize: 16,
                            fontFamily: AppStyles.h3.fontFamily,
                          ),
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
                (myProfile != null)
                    ? Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPage(),
                                ),
                              );
                            },
                          ),
                          if (notifications.where((n) => !n.isRead).isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${notifications.where((n) => !n.isRead).length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Container(),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
      // endDrawer: SideMenu(patient: myProfile),
      body: RefreshIndicator(
        onRefresh: _initialize,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in sections) ...[
                _buildSectionWidget(section),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget servicesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Discover Services".tr(), style: AppStyles.h2.copyWith()),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServicesListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'See All'.tr(),
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (servicesList.isNotEmpty)
          SizedBox(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: servicesList.map((service) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.only(right: 16),
                    child: ServiceCard(
                      label: service.category.tr(),
                      isSelected: false,
                      title: service.titleLocalized(context),
                      description: service.shortDescription(
                        context,
                        maxLength: 100,
                      ),
                      icon: Icons.medical_services,
                      service: service,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget articlesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Blog & Articles".tr(), style: AppStyles.h2.copyWith()),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticlesListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'See All'.tr(),
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.darkTeal),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ArticlesWidget(articlesList: articlesList),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionWidget(SectionModel section) {
    switch (section.key) {
      case 'welcome':
        return myProfile != null
            ? WelcomeProfile(patient: myProfile)
            : SizedBox.shrink();
      case 'videos':
        return VideosSection(
          videosPostersList: _videos.map((v) => v.thumbnailUrl!).toList(),
        );
      case 'doctors':
        return doctorsListSlider();
      case 'calculator':
        return const PregnancyCalculatorBanner();
      case 'services':
        return servicesWidget();
      case 'articles':
        return articlesWidget();
      case 'pill_reminder':
        return PillReminder();
      case 'banner':
        return WelcomeBannerSlider(slides: slides);
      case 'ai_text_banner':
        return const AITextBanner();
      case 'ai_medical_banner':
        return SmartMedicalAnalysisCard();
      case 'bookings':
        return upcomingBookings.isNotEmpty
            ? AppointmentCard(appointment: upcomingBookings.last)
            : SizedBox.shrink();
      case 'location':
        return const LocationCard();
      default:
        return SizedBox.shrink(); // Return empty widget for unknown types
    }
  }

  Widget doctorsListSlider() {
    return DoctorsSlider(categoryIndex: 0);
  }

  Future<void> _fetchProfile() async {
    setState(() {
      myProfile = null;
    });
    if (!sl.storage.isLoggedIn) return;
    final result = await sl.auth.getMyProfile();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        myProfile = PatientModel.fromJson(data.toJson());
      });

      try {
        await sl.pushNotifications.initialize();
      } catch (e) {
        // Handle registration error (e.g., log it)
        debugPrint('Failed to register device token: $e');
      }
    }
  }

  Future<void> _fetchServices() async {
    final result = await sl.hospitalServices.getServices();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        servicesList = data.data;
      });
    }
  }

  List<SectionModel> sections = [];
  Future<void> _fetchSections() async {
    final result = await sl.appConfig.fetchSections();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        sections = data;
      });
    }
  }

  List<SlideModel> slides = [];
  Future<void> _fetchSlides() async {
    final result = await sl.appConfig.fetchSlides();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        slides = data;
      });
    }
  }

  List<NotificationApiModel> notifications = [];
  Future<void> _fetchNotifications() async {
    final result = await sl.notifications.getNotifications();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        notifications = data.data;
      });
    }
  }

  List<AppointmentModel> upcomingBookings = [];

  Future<void> _fetchUpcomingBookings() async {
    if (!sl.storage.isLoggedIn) return;
    final result = await sl.bookings.getMyBookings(status: '4');
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        upcomingBookings = data.data;
      });
    }
  }

  Future<void> _fetchArticles() async {
    final result = await sl.articles.getArticles(page: 1);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          articlesList = data.data;
        });
      case Failure(:final exception):
        setState(() {
          exception.message;
        });
    }
  }

  List<VideoApiModel> _videos = [];

  Future<void> _fetchVideos() async {
    final result = await sl.videos.getVideos(page: 1);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _videos = data.data;
        });
      case Failure(:final exception):
        setState(() {
          exception.message;
        });
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchSlides();
    await _fetchSections();
    await _fetchProfile();

    if (sections.where((s) => s.key == 'videos' && s.isActive).isNotEmpty) {
      await _fetchVideos();
    }
    if (sections.where((s) => s.key == 'bookings' && s.isActive).isNotEmpty) {
      await _fetchUpcomingBookings();
    }
    if (sections.where((s) => s.key == 'services' && s.isActive).isNotEmpty) {
      await _fetchServices();
    }
    if (sections.where((s) => s.key == 'articles' && s.isActive).isNotEmpty) {
      await _fetchArticles();
    }
    if (sections.where((s) => s.key == 'doctors' && s.isActive).isNotEmpty) {
      // No data fetching needed for doctors section
    }

    if (sections
        .where((s) => s.key == 'notifications' && s.isActive)
        .isNotEmpty) {
      await _fetchNotifications();
    }

    sl.analytics.trackScreen('HomePage');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
