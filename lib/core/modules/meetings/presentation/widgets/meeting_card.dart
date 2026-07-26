import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/meetings/presentation/pages/meeting_page.dart';
import 'package:bedaya2/core/modules/meetings/models/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bedaya2/core/theme/styles.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel? meeting;

  const MeetingCard({super.key, this.meeting});

  MeetingModel get _displayMeeting =>
      meeting ??
      MeetingModel(
        id: 0,

        doctorId: 1,
        doctorName: '',
        doctorImageUrl:
            'https://bedayahospitals.com/uploads/images/ismail-abo-alfotouh-673415398a562.webp',
      );

  @override
  Widget build(BuildContext context) {
    if (!sl.storage.isLoggedIn) return Container();
    return GestureDetector(
      onTap: () {
        final checkTime = startMeeting(context);
        if (!checkTime) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingPage(meeting: _displayMeeting),
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
                  'Video Meeting'.tr(),
                  style: AppStyles.whiteTitle.copyWith(fontSize: 18),
                ),
                // Label for appointment status
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
                          _formatDateString(
                            meeting!.selectedDate
                                    ?.toIso8601String()
                                    .split('T')
                                    .first ??
                                '',
                          ),
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
                          "${meeting!.selectedTime}",
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
                      meeting != null && meeting!.doctorImageUrl != null
                          ? meeting!.doctorImageUrl!
                          : 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${meeting?.doctorName}",
                          style: AppStyles.h3.copyWith(fontSize: 14),
                        ),
                        Text("${meeting?.notes}", style: AppStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Start not button
            TextButton(
              onPressed: () {
                final checkTime = startMeeting(context);
                if (!checkTime) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeetingPage(meeting: _displayMeeting),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
              ),

              child: Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  left: 12,
                  right: 12,
                ),
                child: Text(
                  'Start Meeting'.tr(),
                  style: AppStyles.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D7885),
                  ),
                ),
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

  bool startMeeting(BuildContext context) {
    final date =
        "${meeting!.selectedDate?.year}-${meeting!.selectedDate?.month.toString().padLeft(2, '0')}-${meeting!.selectedDate?.day.toString().padLeft(2, '0')}";
    // Validate the date and time of the meeting before joining
    // If the time not started yet, show a message to the user
    // Allow to login before the meeting time with 10 minutes only
    if (meeting?.selectedDate != null && meeting?.selectedTime != null) {
      final meetingDateTime = DateTime.parse('$date ${meeting!.selectedTime}');
      final now = DateTime.now();
      if (now.isBefore(meetingDateTime) &&
          !now.isAfter(meetingDateTime.subtract(const Duration(minutes: 10)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(
              "${'Meeting has not started yet'.tr()} ${'Meeting will start at'.tr()} $date ${'Hour'.tr()}: ${meeting!.selectedTime} ${"You can join the meeting 10 minutes before the start time.".tr()}",
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }
}
