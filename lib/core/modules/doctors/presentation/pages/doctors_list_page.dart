import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_category.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/doctors/presentation/pages/doctor_details_page.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';

import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_appointment_page.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;

  List<DoctorCategory> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesError;

  final Map<String, List<DoctorApiModel>?> _doctorsByCategory = {};
  final Map<String, bool> _loadingDoctors = {};
  final Map<String, String?> _doctorErrors = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    sl.analytics.trackScreen('DoctorsListPage');
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _categoryKey(DoctorCategory category) =>
      category.id == 0 ? 'all' : category.id.toString();

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    final result = await sl.doctors.getCategories();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        _tabController?.dispose();
        final allCategory = DoctorCategory(
          id: 0,
          name: 'All',
          arabicName: 'الكل',
        );
        final categories = [allCategory, ...data];
        _tabController = TabController(length: categories.length, vsync: this)
          ..addListener(() {
            if (_tabController!.indexIsChanging) {
              setState(() => _currentTabIndex = _tabController!.index);
              _loadDoctorsForCategory(categories[_tabController!.index]);
            }
          });
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
        _loadDoctorsForCategory(categories.first);
      case Failure(:final exception):
        setState(() {
          _isLoadingCategories = false;
          _categoriesError = exception.message;
        });
    }
  }

  Future<void> _loadDoctorsForCategory(DoctorCategory category) async {
    final key = _categoryKey(category);
    if (_doctorsByCategory[key] != null) return;
    if (_loadingDoctors[key] == true) return;

    setState(() {
      _loadingDoctors[key] = true;
      _doctorErrors[key] = null;
    });

    final result = await sl.doctors.getDoctors(
      categoryId: category.id == 0 ? null : category.id.toString(),
    );
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _doctorsByCategory[key] = data.data;
          _loadingDoctors[key] = false;
        });
      case Failure(:final exception):
        setState(() {
          _doctorsByCategory[key] = [];
          _loadingDoctors[key] = false;
          _doctorErrors[key] = exception.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Our Doctors'.tr(),
          style: AppStyles.h2.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        bottom:
            (!_isLoadingCategories &&
                _categoriesError == null &&
                _tabController != null)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController!,
                    isScrollable: true,
                    labelColor: AppColors.primaryTeal,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppStyles.h3.copyWith(fontSize: 15),
                    unselectedLabelStyle: AppStyles.bodyMedium,
                    indicatorColor: AppColors.primaryTeal,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabAlignment: TabAlignment.start,
                    tabs: _categories.map((category) {
                      final categoryIndex = _categories.indexOf(category);
                      final isSelected = _currentTabIndex == categoryIndex;
                      final key = _categoryKey(category);
                      final count = _doctorsByCategory[key]?.length ?? 0;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${context.locale == Locale('ar') ? category.arabicName : category.name}",
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryTeal.withValues(
                                        alpha: 0.15,
                                      )
                                    : AppColors.greyOutline.withValues(
                                        alpha: 0.3,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count',
                                style: AppStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryTeal
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_categoriesError != null) {
      return _buildErrorState(_categoriesError!, _loadCategories);
    }
    if (_tabController == null) {
      return const SizedBox.shrink();
    }
    return TabBarView(
      controller: _tabController!,
      children: _categories.map((category) {
        final key = _categoryKey(category);
        final isLoading = _loadingDoctors[key] == true;
        final error = _doctorErrors[key];
        final doctors = _doctorsByCategory[key];

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error != null) {
          return _buildErrorState(
            error,
            () => _loadDoctorsForCategory(category),
          );
        }
        if (doctors == null || doctors.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDoctorGrid(doctors);
      }).toList(),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: AppColors.greyOutline,
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors available'.tr(),
            style: AppStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text('Please check back later'.tr(), style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDoctorGrid(List<DoctorApiModel> doctors) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
        mainAxisExtent: 170,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return _buildDoctorCard(doctors[index]);
      },
    );
  }

  Widget _buildDoctorCard(DoctorApiModel doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailsPage(doctor: doctor),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.greyOutline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Image
            Container(
              margin: const EdgeInsets.only(top: 26, left: 8),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  doctor.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.lightBlueBackground,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryTeal,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Doctor Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialty Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doctor.specialty.tr(),
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Doctor Name
                    Text(
                      context.locale == Locale('ar')
                          ? doctor.arabicName
                          : doctor.name,
                      style: AppStyles.h3.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.ratingGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toString(),
                          style: AppStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${doctor.experienceYears}y)',
                          style: AppStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    // Book Button
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingAppointmentPage(
                                preselectedDoctor: doctor,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Book Now'.tr(),
                          style: AppStyles.buttonText.copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
