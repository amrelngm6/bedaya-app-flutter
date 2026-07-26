import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/bookings/models/appointment_model.dart';
import 'package:bedaya2/core/modules/bookings/presentation/pages/booking_details_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/styles.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel? appointment;

  const AppointmentCard({super.key, this.appointment});

  AppointmentModel get _displayAppointment =>
      appointment ??
      const AppointmentModel(
        id: 0,
        doctorId: 1,
        doctorName: '',
        doctorSpecialty: '',
        doctorImageUrl:
            'https://bedayahospitals.com/uploads/images/ismail-abo-alfotouh-673415398a562.webp',
        bookingType: '',
        appointmentDate: '',
        appointmentTime: '',
        status: '',
        cost: 0.0,
      );

  @override
  Widget build(BuildContext context) {
    if (!sl.storage.isLoggedIn) return Container();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingDetailsPage(appointment: _displayAppointment),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1D7885), // Teal background
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'upcoming_appointments'.tr(),
                  style: AppStyles.whiteTitle.copyWith(fontSize: 18),
                ),
                // Label for appointment status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: appointment != null
                        ? (appointment!.isConfirmed
                              ? Colors.green
                              : appointment!.isCancelled
                              ? Colors.red
                              : appointment!.isCompleted
                              ? Colors.blue
                              : Colors.orange)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment != null
                        ? 'booking_status_${appointment!.status}'.tr()
                        : 'no_appointments'.tr(),
                    style: AppStyles.whiteBody.copyWith(fontSize: 12),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateString(appointment!.appointmentDate),
                          style: AppStyles.whiteBody.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'date'.tr(),
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment!.appointmentTime,
                          style: AppStyles.whiteBody.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'time'.tr(),
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      appointment!.doctorImageUrl.isNotEmpty
                          ? appointment!.doctorImageUrl
                          : 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment!.doctorName,
                          style: AppStyles.h3.copyWith(fontSize: 14),
                        ),
                        Text(
                          appointment!.doctorSpecialty,
                          style: AppStyles.bodySmall,
                        ),
                      ],
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
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
