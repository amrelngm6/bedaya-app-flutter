import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_category.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/doctors/presentation/pages/doctors_list_page.dart';
import 'package:bedaya2/core/modules/doctors/presentation/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/presentation/widgets/category_chip.dart';

class DoctorsSlider extends StatefulWidget {
  const DoctorsSlider({super.key, required this.categoryIndex});
  final int categoryIndex;

  @override
  State<DoctorsSlider> createState() => _DoctorsSliderState();
}

class _DoctorsSliderState extends State<DoctorsSlider> {
  int _selectedCategoryIndex = 0;
  List<dynamic> _categories = [];

  // Doctor data structure
  final Map<int, List<DoctorApiModel>> _doctorsByCategory = {};

  List<DoctorApiModel> get _filteredDoctors {
    if (_categories.isEmpty) return [];

    // return doctors who have specialty matching any of the categories (except "All")
    final allDoctors = _doctorsByCategory.values.expand((list) => list).where((
      doctor,
    ) {
      if (_selectedCategoryIndex == 0) return true; // "All" category
      final selectedCategory = _categories[_selectedCategoryIndex]['name'];
      return doctor.specialty == selectedCategory;
    }).toList();

    return allDoctors.cast<DoctorApiModel>();
  }

  String _translateCategoryName(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final categoryName = context.locale == const Locale('ar')
        ? category['arabicName'] ?? ''
        : category['name'] ?? '';
    return categoryName;
  }

  TabController? _tabController;

  final Map<String, bool> _loadingDoctors = {};
  final Map<String, String?> _doctorErrors = {};

  String _categoryKey(DoctorCategory category) =>
      category.id == 0 ? 'all' : category.id.toString();

  Future<void> _loadCategories() async {
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
        setState(() {
          _categories = categories
              .map(
                (c) => {'id': c.id, 'name': c.name, 'arabicName': c.arabicName},
              )
              .toList();
        });
        _loadDoctorsForCategory(categories.first);
      case Failure(:final exception):
        setState(() {
          exception;
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

    if (_doctorsByCategory.isNotEmpty) {
      return;
    }

    final result = await sl.doctors.getDoctors();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _doctorsByCategory[category.id] = data.data.cast<DoctorApiModel>();
          _loadingDoctors[key] = false;
        });
      case Failure(:final exception):
        setState(() {
          _doctorsByCategory[category.id] = [];
          _loadingDoctors[key] = false;
          _doctorErrors[key] = exception.message;
        });
    }
  }

  @override
  void initState() {
    super.initState();

    // Delay to ensure the widget is fully built before fetching data
    Future.delayed(Duration(seconds: 2), () {
      _loadCategories();
      _loadDoctorsForCategory(
        DoctorCategory(id: 0, name: 'All', arabicName: 'الكل'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Doctors'.tr(), style: AppStyles.h2),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorsListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    'See All'.tr(),
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_categories.length, (index) {
                return CategoryChip(
                  label: _translateCategoryName(context, _categories[index]),
                  isSelected: _selectedCategoryIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;

                      // Filter _doctorsByCategory based on selected category
                      _loadDoctorsForCategory(
                        DoctorCategory(
                          id: index == 0 ? 0 : index,
                          name: _categories[index]['name'] ?? '',
                          arabicName: _categories[index]['arabicName'] ?? '',
                        ),
                      );
                      sl.analytics.trackTap(
                        'category_change_tap',
                        screenName:
                            'DoctorsSlider - ${_categories[index]['name'] ?? ''}',
                      );
                    });
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Doctors List
          _filteredDoctors.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'no_doctors_available'.tr(),
                      style: AppStyles.bodySmall,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filteredDoctors.map((doctor) {
                      return DoctorCard(doctor: doctor);
                    }).toList(),
                  ),
                ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
