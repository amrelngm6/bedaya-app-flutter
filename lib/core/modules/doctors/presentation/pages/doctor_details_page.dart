import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';
import 'package:bedaya2/core/network/network_result.dart';
// import 'package:bedaya2/core/modules/doctors/models/doctor_review.dart';
import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_appointment_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/doctors/models/doctor_model.dart';
import 'package:html2md/html2md.dart' as html2md;

class DoctorDetailsPage extends StatefulWidget {
  final DoctorApiModel doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  // List<DoctorReview> _reviews = [];
  // bool _isLoadingReviews = false;
  // String? _reviewsError;

  @override
  void initState() {
    super.initState();
    // _loadReviews();
    sl.analytics.trackScreen('DoctorDetailsPage - ${widget.doctor.name.tr()}');
    _loadDoctorDetails();
  }

  Future<void> _loadDoctorDetails() async {
    final result = await sl.doctors.getDoctorById(widget.doctor.id);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          doc = data;
        });
      case Failure():
        setState(() {
          doc = widget.doctor;
        });
        break;
    }
  }

  /**
  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    final result = await sl.doctors.getReviews(doctorId: widget.doctor.id);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _reviews = data.data;
          _isLoadingReviews = false;
        });
      case Failure(:final exception):
        setState(() {
          _isLoadingReviews = false;
          _reviewsError = exception.message;
        });
    }
  }
   */

  DoctorApiModel doc = DoctorApiModel(
    id: 0,
    name: '',
    arabicName: '',
    categoryId: 0,
    imageUrl: '',
    specialty: '',
    arabicSpecialty: '',
    rating: 0.0,
    reviewsCount: 0,
    experienceYears: 0,
    consultationFee: 0.0,
    availableBookingTypes: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          context.locale == Locale('ar') ? doc.arabicName : doc.name,
          style: AppStyles.h3,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: doc.isLikedByMe == true ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              if (sl.storage.isLoggedIn) {
                sl.doctors.toggleLike(doc.id);
              } else {
                return _checkAuthAndProceed(back: false);
              }

              setState(() {
                doc.isLikedByMe = !(doc.isLikedByMe ?? false);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Doctor Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // 2. Action Buttons (Booking)
            _buildActionButtons(context),
            const SizedBox(height: 24),

            // 3. Stats Row
            _buildStatsRow(),
            const SizedBox(height: 24),

            // 4. About Doctor
            Text("About Doctor".tr(), style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              html2md.convert(
                "${(Locale("ar") == Localizations.localeOf(context) ? doc.bioArabic : doc.bio)}",
              ),
              style: AppStyles.bodyMedium.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            // 5. Media (Videos & Photos)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text("Videos & Photos".tr(), style: AppStyles.h2),
            //     TextButton(
            //       onPressed: () {},
            //       child: Text(
            //         "View All".tr(),
            //         style: AppStyles.bodyMedium.copyWith(
            //           color: AppColors.primaryPurple,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // _buildMediaSection(),
            const SizedBox(height: 24),

            // 6. Reviews
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Row(
            //       children: [
            //         Text("Rating".tr(), style: AppStyles.h2),
            //         const SizedBox(width: 8),
            //         Container(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 8,
            //             vertical: 2,
            //           ),
            //           decoration: BoxDecoration(
            //             color: AppColors.ratingGold.withValues(alpha: 0.2),
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           child: Row(
            //             children: [
            //               const Icon(
            //                 Icons.star,
            //                 size: 14,
            //                 color: AppColors.ratingGold,
            //               ),
            //               const SizedBox(width: 4),
            //               Text(
            //                 "${doc.rating}",
            //                 style: AppStyles.bodySmall.copyWith(
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.black,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //     TextButton(
            //       onPressed: () {},
            //       child: Text(
            //         "".tr(),
            //         style: AppStyles.bodyMedium.copyWith(
            //           color: AppColors.primaryPurple,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 12),
            // _buildReviewsSection(),
            // const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /**
  Widget _buildReviewsSection() {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_reviewsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                _reviewsError!,
                style: AppStyles.bodyMedium.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              TextButton(onPressed: _loadReviews, child: Text('Retry'.tr())),
            ],
          ),
        ),
      );
    }
    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No reviews yet'.tr(),
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
    return Column(
      children: _reviews
          .map(
            (r) => _buildReviewItem(
              r.patientName,
              r.rating,
              r.comment,
              r.createdAt,
            ),
          )
          .toList(),
    );
  }
 */

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Image.network(
            doc.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.lightBlueBackground,
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.locale == Locale('ar')
                      ? doc.arabicSpecialty
                      : doc.specialty,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.darkTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(doc.name.tr(), style: AppStyles.h3),
              const SizedBox(height: 4),
              Text('Specialist'.tr(), style: AppStyles.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Bedaya Hospital, Dokki, Giza".tr(),
                      style: AppStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingAppointmentPage(
                    preselectedDoctor: widget.doctor,
                    preselectedBookingType: 'in-person',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Text(
              "Book a Visit".tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (widget.doctor.hasOnlineBooking == true)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingAppointmentPage(
                      preselectedDoctor: widget.doctor,
                      preselectedBookingType: 'online',
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Online Consult".tr(),
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.people_outline, "Patients".tr(), "5000+"),
          _buildStatInfoDivider(),
          _buildStatItem(
            Icons.work_outline,
            "Experience".tr(),
            "${doc.experienceYears} ${'years'.tr()}",
          ),
          _buildStatInfoDivider(),
          _buildStatItem(Icons.star_border, "Rating".tr(), "${doc.rating}"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppStyles.h3.copyWith(fontSize: 16)),
        Text(label, style: AppStyles.bodySmall),
      ],
    );
  }

  Widget _buildStatInfoDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  /**
  Widget _buildMediaSection() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(
                  "https://picsum.photos/300/200?random=$index",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: index == 0
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }


  Widget _buildReviewItem(
    String reviewerName,
    double rating,
    String comment,
    String date,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.greyOutline,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reviewerName,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(date, style: AppStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) =>
                const Icon(Icons.star, color: AppColors.ratingGold),
            itemCount: 5,
            itemSize: 16.0,
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 8),
          Text(comment, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }
  */

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
    if (mounted && back == true && !sl.storage.isLoggedIn) {
      Navigator.pop(context);
    }
  }

  /// --- Helper to check auth before booking ---
  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }
}
