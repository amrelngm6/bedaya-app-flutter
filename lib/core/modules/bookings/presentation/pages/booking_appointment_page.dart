import 'dart:async';

import 'package:bedaya2/core/modules/auth/models/auth_models.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';
import 'package:bedaya2/core/modules/doctors/models/available_slot.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/bookings/services/booking_service.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/modules/bookings/models/new_appointment_model.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'booking_success_page.dart';

class BookingAppointmentPage extends StatefulWidget {
  final DoctorApiModel? preselectedDoctor;
  final String? preselectedBookingType;

  const BookingAppointmentPage({
    super.key,
    this.preselectedDoctor,
    this.preselectedBookingType,
  });

  @override
  State<BookingAppointmentPage> createState() => _BookingAppointmentPageState();
}

class _BookingAppointmentPageState extends State<BookingAppointmentPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final NewAppointmentModel _booking = NewAppointmentModel();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  UserModel? currentUser;
  // Doctors from API
  List<DoctorApiModel> _doctors = [];
  DoctorApiModel? selectedDoctor;
  bool _isLoadingDoctors = true;
  String? _doctorsError;

  // Availability slots from API
  List<AvailabilitySlot> _availabilitySlots = [];
  bool _isLoadingSlots = false;
  int? _selectedSlotId;

  // Submission state
  bool _isSubmitting = false;

  // User authentication state
  // final bool _isAuthenticated = sl.auth.getCurrentUser() != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _loadCurrentUser();
    _loadDoctors();
    _checkAuthAndProceed(back: false);

    selectedDoctor = widget.preselectedDoctor;

    if (selectedDoctor != null) {
      final d = selectedDoctor!;
      _booking.doctorId = d.id;
      _booking.doctorName = d.name;
      _booking.doctorSpecialty = d.specialty;
      _booking.doctorImageUrl = d.imageUrl;

      Timer(const Duration(milliseconds: 600), () {
        if (mounted) _nextStep();
      });
    }
    if (widget.preselectedBookingType != null) {
      setState(() {
        _booking.bookingType = widget.preselectedBookingType == 'online'
            ? BookingType.online
            : BookingType.inPerson;
      });
      Timer(const Duration(milliseconds: 600), () {
        if (mounted) print(currentUser);
      });
    }
    sl.analytics.trackScreen('BookingAppointmentPage');
  }

  Future<void> _loadCurrentUser() async {
    final result = await sl.auth.getMyProfile();
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() => currentUser = data);
      case Failure():
        setState(() => currentUser = null);
    }
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _doctorsError = null;
    });
    final result = await sl.doctors.getDoctors(perPage: 50);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _doctors = data.data;
          _isLoadingDoctors = false;
          // If a preselected doctor isn't already in the list, inject it
          if (selectedDoctor != null &&
              !_doctors.any((d) => d.id == selectedDoctor!.id)) {
            _doctors = [selectedDoctor!, ..._doctors];
          }
        });
      case Failure(:final exception):
        setState(() {
          _isLoadingDoctors = false;
          _doctorsError = exception.message;
          // Keep preselected doctor available even if list fetch failed
          if (selectedDoctor != null) {
            _doctors = [selectedDoctor!];
          }
        });
    }
  }

  Future<void> _loadAvailabilitySlots() async {
    if (_booking.doctorId == null || _booking.selectedDate == null) return;
    setState(() {
      _isLoadingSlots = true;
      _availabilitySlots = [];
      _selectedSlotId = null;
      _booking.selectedTime = null;
    });
    final date = _booking.selectedDate!;
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final bookingType = _booking.bookingType == BookingType.online
        ? 'online'
        : 'in_person';
    final result = await sl.doctors.getWorkingHours(
      doctorId: _booking.doctorId!,
      date: dateStr,
      bookingType: bookingType,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _availabilitySlots = data;
          _isLoadingSlots = false;
        });
      case Failure():
        setState(() => _isLoadingSlots = false);
    }
  }

  // ─── Auth Gate ────────────────────────────────────────────────────────────

  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }

  Future<void> _showAuthModal({bool? back = false}) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetCtx) => AuthRequiredSheet(
        onNavigateToLogin: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onNavigateToRegister: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onGoBack: () {
          Navigator.pop(sheetCtx);
          if (mounted) Navigator.pop(context);
        },
      ),
    );

    // If the modal was closed without authenticating, leave the booking page.
    if (mounted && !sl.storage.isLoggedIn && back == true) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_isSubmitting) return;
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    } else {
      _confirmBooking();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _confirmBooking() async {
    if (_booking.doctorId == null || _booking.bookingType == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CreateBookingRequest(
      doctorId: _booking.doctorId!,
      // slotId: _selectedSlotId!,
      cost: _booking.cost,
      serviceId: _booking.serviceId,
      slotId: 1,
      bookingType: _booking.bookingType == BookingType.online
          ? 'online'
          : 'in_person',
      notes: _booking.notes,
      startTime:
          '00:00', // Placeholder, as the API requires a start time even if it's not used
      bookingDate: _booking.selectedDate.toString(),
      title:
          '${_booking.doctorName} - ${_booking.bookingType == BookingType.online ? 'Online' : 'In-Person'} Consultation',
    );

    final result = await sl.bookings.createBooking(request);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    switch (result) {
      case Success(:final data):
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingSuccessPage(appointment: data),
              ),
            );
          }
        });
      case Failure(:final exception):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _booking.isDoctorSelected;
      case 1:
        return _booking.isBookingTypeSelected;
      case 2:
        return _booking.selectedDate != null;
      /**&& _selectedSlotId != null*/
      case 3:
        return true; // Notes are optional
      case 4:
        return _booking.isDoctorSelected &&
            _booking.isBookingTypeSelected &&
            _booking.selectedDate != null;
      // &&
      // _selectedSlotId != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _currentStep == 0
              ? () => Navigator.pop(context)
              : _previousStep,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Appointment'.tr(),
              style: AppStyles.h2.copyWith(fontSize: 20),
            ),
            Text(
              '${'Step'.tr()} ${_currentStep + 1}/5',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDoctorSelection(),
                _buildBookingTypeSelection(),
                _buildScheduleSelection(),
                _buildNotesSection(),
                _buildConfirmation(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppColors.primaryTeal
                    : AppColors.greyOutline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Doctor'.tr(), style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred specialist'.tr(),
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (_isLoadingDoctors)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_doctorsError != null && _doctors.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _doctorsError!,
                        style: AppStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDoctors,
                        child: Text('Retry'.tr()),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._doctors.map((doctor) => _buildDoctorCard(doctor)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorApiModel doctor) {
    final isSelected = _booking.doctorId == doctor.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDoctor = doctor;
          _booking.doctorId = doctor.id;
          _booking.doctorName = doctor.name;
          _booking.doctorSpecialty = doctor.specialty;
          _booking.doctorImageUrl = doctor.imageUrl;
          // Reset schedule when doctor changes
          _booking.selectedDate = null;
          _booking.selectedTime = null;
          _selectedSlotId = null;
          _availabilitySlots = [];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.greyOutline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryTeal.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTeal, width: 2),
                image: DecorationImage(
                  image: NetworkImage(doctor.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name.tr(),
                    style: AppStyles.h3.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(doctor.specialty.tr(), style: AppStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.ratingGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.rating.toString(),
                        style: AppStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.work_outline,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.experienceYears} ${'years'.tr()}',
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryTeal : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryTeal
                          : AppColors.greyOutline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTypeSelection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit Type'.tr(), style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              'How would you like to consult?'.tr(),
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            for (DoctorService service in selectedDoctor?.services ?? [])
              _buildBookingTypeCard(
                service: service,
                type: service.isOnline
                    ? BookingType.online
                    : BookingType.inPerson,
                icon: service.isOnline
                    ? Icons.video_call
                    : Icons.local_hospital,
                title: context.locale == Locale('ar')
                    ? service.arabicName ?? service.name
                    : service.name,
                description: service.isOnline
                    ? 'Online Consultation'.tr()
                    : 'Visit the hospital for consultation'.tr(),
                price: service.getPriceForUserType(
                  "${currentUser?.nationalityType}",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTypeCard({
    required DoctorService service,
    required BookingType type,
    required IconData icon,
    required String title,
    required String description,
    required double price,
    String? discount,
  }) {
    final isSelected = _booking.serviceId == service.id;
    return GestureDetector(
      onTap: () => _confirmBookingType(service, type, price),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.greyOutline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryTeal.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryTeal.withValues(alpha: 0.1)
                        : AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? AppColors.primaryTeal
                        : AppColors.darkTeal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppStyles.h3.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(description, style: AppStyles.bodyMedium),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EGP ${price.toInt()}',
                            style: AppStyles.h3.copyWith(
                              color: AppColors.primaryTeal,
                              fontSize: 18,
                            ),
                          ),

                          if (discount != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.onlineGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                discount,
                                style: AppStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryTeal : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryTeal
                          : AppColors.greyOutline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Icon(
                service.isOnline ? Icons.video_call : Icons.local_hospital,
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppColors.greyOutline,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSelection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Schedule'.tr(), style: AppStyles.h2),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 32),
            _buildTimeSlotSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final dates = List.generate(7, (index) => today.add(Duration(days: index)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              _booking.selectedDate != null &&
              _booking.selectedDate!.day == date.day &&
              _booking.selectedDate!.month == date.month;

          return GestureDetector(
            onTap: () {
              setState(() {
                _booking.selectedDate = date;
              });
              _loadAvailabilitySlots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              margin: EdgeInsets.only(right: index < dates.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryTeal : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : AppColors.greyOutline,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekday(date.weekday),
                    style: AppStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: AppStyles.h2.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }

  Widget _buildTimeSlotSelector() {
    if (_booking.selectedDate == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Select a date to see available slots'.tr(),
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_isLoadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availabilitySlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Time will be defined and we will inform you'.tr(),
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return _buildTimeSlotGrid(_availabilitySlots);
  }

  Widget _buildTimeSlotGrid(List<AvailabilitySlot> slots) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final isSelected = _selectedSlotId == slot.slotId;
        final displayTime = slot.startTime.length >= 5
            ? slot.startTime.substring(0, 5)
            : slot.startTime;
        return GestureDetector(
          onTap: slot.isAvailable
              ? () {
                  setState(() {
                    _selectedSlotId = slot.slotId;
                    _booking.selectedTime = displayTime;
                  });
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryTeal
                  : slot.isAvailable
                  ? Colors.white
                  : AppColors.greyOutline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryTeal
                    : slot.isAvailable
                    ? AppColors.greyOutline
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              displayTime,
              style: AppStyles.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : slot.isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Additional Notes'.tr(), style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Any specific concerns or questions? (Optional)'.tr(),
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greyOutline.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Describe your symptoms or concerns...'.tr(),
                  hintStyle: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: AppStyles.bodyLarge,
                onChanged: (value) {
                  _booking.notes = value;
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryTeal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your information is kept confidential and will only be shared with your doctor.'
                          .tr(),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.darkTeal,
                        height: 1.5,
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

  Widget _buildConfirmation() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Booking'.tr(), style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Please review your appointment details'.tr(),
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            // _buildQRCodeWidget(),
            const SizedBox(height: 24),
            _buildConfirmationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.1),
            AppColors.lightBlueBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildConfirmationRow(
            Icons.person,
            'Doctor'.tr(),
            _booking.doctorName ?? '',
            _booking.doctorSpecialty ?? '',
          ),
          const Divider(height: 32),
          _buildConfirmationRow(
            _booking.bookingType == BookingType.inPerson
                ? Icons.local_hospital
                : Icons.video_call,
            'Visit Type'.tr(),
            _booking.bookingType == BookingType.inPerson
                ? 'In-Person Visit'.tr()
                : 'Online Consultation'.tr(),
            '',
          ),
          const Divider(height: 32),
          _buildConfirmationRow(
            Icons.calendar_today,
            'Date & Time'.tr(),
            _formatDate(_booking.selectedDate),
            _booking.selectedTime ?? '',
          ),
          const Divider(height: 32),
          _buildConfirmationRow(
            Icons.attach_money,
            'Consultation Fee'.tr(),
            'EGP ${_booking.cost?.toInt() ?? 0}',
            '',
          ),
          if (_booking.hasNotes) ...[
            const Divider(height: 32),
            _buildConfirmationRow(
              Icons.note_alt,
              'Notes'.tr(),
              _booking.notes ?? '',
              '',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(
    IconData icon,
    String label,
    String value,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppStyles.h3.copyWith(fontSize: 16)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: AppStyles.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_canContinue() && !_isSubmitting) ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.greyOutline,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: (_canContinue() && !_isSubmitting) ? 4 : 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == 4
                        ? 'Confirm Booking'.tr()
                        : 'Continue'.tr(),
                    style: AppStyles.buttonText.copyWith(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  void _confirmBookingType(
    DoctorService service,
    BookingType type,
    double price,
  ) {
    setState(() {
      _booking.serviceId = service.id;
      _booking.bookingType = type;
      _booking.cost = service.getPriceForUserType(
        "${currentUser?.nationalityType}",
      );

      // Reset slot when visit type changes
      _selectedSlotId = null;
      _booking.selectedTime = null;
      _availabilitySlots = [];
    });
    // Reload slots if a date was already selected
    if (_booking.selectedDate != null) {
      _loadAvailabilitySlots();
    }
  }
}
