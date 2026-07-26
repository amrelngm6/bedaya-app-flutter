import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/bookings/models/appointment_model.dart';
import 'package:bedaya2/core/modules/doctors/presentation/pages/doctor_details_page.dart';
import 'package:bedaya2/core/modules/meetings/presentation/widgets/meeting_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/theme/styles.dart';

class BookingDetailsPage extends StatefulWidget {
  final AppointmentModel appointment;

  const BookingDetailsPage({super.key, required this.appointment});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AppointmentModel appointment;

  @override
  void initState() {
    super.initState();
    appointment = widget.appointment;

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _playAnimations();
  }

  void _playAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
  }

  String cancellationReason = '';
  Future<void> _cancelAppointment() async {
    if (appointment.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This appointment is already cancelled.'.tr()),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment'.tr()),
        content: Text('Are you sure you want to cancel this appointment?'.tr()),
        actions: [
          TextField(
            onChanged: (value) {
              cancellationReason = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter cancellation reason (optional)'.tr(),
            ),
          ),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await sl.bookings.cancelBooking(
        appointment.id,
        reason: cancellationReason.isNotEmpty
            ? cancellationReason
            : 'Cancelled by user',
      );

      setState(() {
        appointment = response.dataOrNull!;
      });

      // Implement cancellation logic here (e.g., API call)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This appointment has been cancelled.'.tr()),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Booking ${appointment.status}!'.tr(),
                        style: AppStyles.h1.copyWith(
                          color: AppColors.primaryTeal,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                (appointment.isCancelled || appointment.isOnline)
                    ? SizedBox.shrink()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildQRCodeWidget(),
                      ),
                const SizedBox(height: 24),

                // Display metting card
                if (appointment.isOnline && appointment.meeting != null)
                  SizedBox(child: MeetingCard(meeting: appointment.meeting)),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAppointmentCard(),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightBlueBackground, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Booking ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.confirmation_number,
                  size: 16,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  '${'Booking ID'.tr()}: #${appointment.id}',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Doctor Info
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DoctorDetailsPage(doctor: appointment.doctor!),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryTeal, width: 2),
                    image: appointment.doctorImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(appointment.doctorImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: appointment.doctorImageUrl.isEmpty
                      ? const Icon(Icons.person, color: AppColors.primaryTeal)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: AppStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.doctorSpecialty,
                        style: AppStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Appointment Details
          _buildDetailRow(
            Icons.calendar_today,
            'date'.tr(),
            _formatDateString(appointment.appointmentDate),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.access_time,
            'time'.tr(),
            appointment.appointmentTime,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            appointment.bookingType == 'in_person'
                ? Icons.local_hospital
                : Icons.video_call,
            'Type'.tr(),
            appointment.bookingType == 'in_person'
                ? 'In-Person Visit'.tr()
                : 'Online Consultation'.tr(),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.attach_money,
            'fee'.tr(),
            'EGP ${appointment.cost.toInt()}',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.info_outline,
            'Status'.tr(),
            appointment.status[0].toUpperCase() +
                appointment.status.substring(1),
          ),
          if (appointment.meetingLink != null &&
              appointment.meetingLink!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.video_call,
              'Meeting Link'.tr(),
              appointment.meetingLink!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryTeal),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildQRCodeWidget() {
    final qrData =
        'BEDAYA_BOOKING|ID:${appointment.id}'
        '|DR:${appointment.doctorName}'
        '|DATE:${appointment.appointmentDate}'
        '|TIME:${appointment.appointmentTime}'
        '|TYPE:${appointment.bookingType.toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryTeal.withValues(alpha: 0.15), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: AppColors.primaryTeal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Code'.tr(),
                      style: AppStyles.h3.copyWith(
                        color: AppColors.primaryTeal,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.appointment.isOnline
                          ? ''
                          : 'Scan on arrival for check-in'.tr(),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greyOutline.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (cxt, err) {
                    return Container(
                      width: 220,
                      height: 220,
                      alignment: Alignment.center,
                      child: Text(
                        'QR Code Error'.tr(),
                        style: AppStyles.bodySmall,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${'Booking ID'.tr()}: #${appointment.id}',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.darkTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Important Information'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildQRInfoItem('Arrive 15 minutes before your appointment'),
                _buildQRInfoItem('Scan QR code at reception desk'),
                // _buildQRInfoItem('Keep this code accessible on your device'),
                _buildQRInfoItem('Screenshot recommended for offline access'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "• ${text.tr()}",
        style: AppStyles.bodySmall.copyWith(
          color: AppColors.darkTeal,
          height: 1.4,
          fontSize: 13,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        appointment.status != 'pending'
            ? SizedBox.shrink()
            : SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Cancel appointment
                    _cancelAppointment();
                  },
                  icon: const Icon(Icons.cancel),
                  label: Text(
                    'Cancel this appointment'.tr(),
                    style: AppStyles.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
        const SizedBox(height: 16),
        // appointment.status != 'pending' && !appointment.isCancelled
        appointment.status != '' && !appointment.isCancelled
            ? SizedBox.shrink()
            : SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add to calendar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to calendar'.tr()),
                        backgroundColor: AppColors.onlineGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    'Add to Calendar'.tr(),
                    style: AppStyles.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // Use post-frame callback to avoid navigation lock
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            },
            icon: const Icon(Icons.home),
            label: Text(
              'Back to Home'.tr(),
              style: AppStyles.buttonText.copyWith(
                color: AppColors.primaryTeal,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryTeal, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: AppColors.lightBlueBackground.withValues(alpha: 0.5),
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 24),
        //       const SizedBox(width: 12),
        //       Expanded(
        //         child: Text(
        //           'A confirmation email has been sent to your registered email address.'
        //               .tr(),
        //           style: AppStyles.bodySmall.copyWith(
        //             color: AppColors.darkTeal,
        //             height: 1.5,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

// Custom painter for animated checkmark
class CheckMarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckMarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Define checkmark points
    final point1 = Offset(centerX - 25, centerY);
    final point2 = Offset(centerX - 5, centerY + 20);
    final point3 = Offset(centerX + 30, centerY - 25);

    if (progress < 0.5) {
      // Draw first part of checkmark
      final currentProgress = progress * 2;
      path.moveTo(point1.dx, point1.dy);
      path.lineTo(
        point1.dx + (point2.dx - point1.dx) * currentProgress,
        point1.dy + (point2.dy - point1.dy) * currentProgress,
      );
    } else {
      // Draw complete first part and second part
      final currentProgress = (progress - 0.5) * 2;
      path.moveTo(point1.dx, point1.dy);
      path.lineTo(point2.dx, point2.dy);
      path.lineTo(
        point2.dx + (point3.dx - point2.dx) * currentProgress,
        point2.dy + (point3.dy - point2.dy) * currentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
