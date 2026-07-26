import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/services/presentation/pages/service_details_page.dart';

class ServicesListPage extends StatefulWidget {
  const ServicesListPage({super.key});

  @override
  State<ServicesListPage> createState() => _ServicesListPageState();
}

class _ServicesListPageState extends State<ServicesListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<String> _categories = ['All'];
  Map<String, List<HospitalServiceApiModel>> _servicesByCategory = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadServices();
    sl.analytics.trackScreen('ServicesListPage');
  }

  Future<void> _loadServices() async {
    final result = await sl.hospitalServices.getServices(perPage: 100);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        final services = data.data;
        final categorySet = <String>{};
        for (final s in services) {
          if (s.category.isNotEmpty) categorySet.add(s.category);
        }
        final categories = ['All', ...categorySet.toList()..sort()];
        final byCategory = <String, List<HospitalServiceApiModel>>{
          'All': services,
          for (final cat in categorySet)
            cat: services.where((s) => s.category == cat).toList(),
        };
        _tabController.dispose();
        _tabController = TabController(length: categories.length, vsync: this);
        _tabController.addListener(() {
          if (_tabController.indexIsChanging) {
            setState(() => _currentTabIndex = _tabController.index);
          }
        });
        setState(() {
          _categories = categories;
          _servicesByCategory = byCategory;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _isLoading = false;
          _error = exception.message;
        });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Our Services'.tr(),
          style: AppStyles.h2.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
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
              onTap: (value) => {
                sl.analytics.trackTap(
                  'category_change_tap',
                  screenName: 'ServicesListPage - ${_categories[value]}',
                ),
              },
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppStyles.h3.copyWith(fontSize: 15),
              unselectedLabelStyle: AppStyles.bodyMedium,
              indicatorColor: AppColors.primaryPurple,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabAlignment: TabAlignment.start,
              tabs: _categories.map((category) {
                final categoryIndex = _categories.indexOf(category);
                final isSelected = _currentTabIndex == categoryIndex;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.tr()),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPurple.withValues(alpha: 0.15)
                              : AppColors.greyOutline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_servicesByCategory[category]?.length ?? 0}',
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryPurple
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
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.greyOutline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: AppStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final services = _servicesByCategory[category] ?? [];
                return _buildServicesList(services);
              }).toList(),
            ),
    );
  }

  Widget _buildServicesList(List<HospitalServiceApiModel> services) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 80,
              color: AppColors.greyOutline,
            ),
            const SizedBox(height: 16),
            Text(
              'No services available',
              style: AppStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text('Please check back later', style: AppStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index]);
      },
    );
  }

  Widget _buildServiceCard(HospitalServiceApiModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(service: service),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.greyOutline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.network(
                    service.coverImageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: AppColors.lightBlueBackground,
                        child: Center(
                          child: Icon(
                            Icons.medical_services,
                            size: 60,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        service.category.tr(),
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.ratingGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (service.successRate ?? 0.0).toStringAsFixed(1),
                            style: AppStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Service Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    context.locale.languageCode == 'ar'
                        ? service.arabicTitle
                        : service.title,
                    style: AppStyles.h2.copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    service.shortDescription(context, maxLength: 100),
                    style: AppStyles.bodyMedium,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      // Duration
                      if (service.durationDays != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.durationDays} ${'days'.tr()}',
                          style: AppStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // Reviews
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.successStories.length} ${'reviews'.tr()}',
                        style: AppStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Learn More Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceDetailsPage(service: service),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Learn More'.tr(),
                            style: AppStyles.buttonText.copyWith(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
