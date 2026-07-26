import '../modules/notifications/models/notification_model.dart';

class SampleNotificationsData {
  static List<NotificationModel> getNotifications() {
    final now = DateTime.now();

    return [
      // Appointment Notifications
      NotificationModel(
        id: '1',
        type: NotificationType.appointment,
        title: 'Appointment Reminder',
        message:
            'Your consultation with Dr. Ahmed Hassan is tomorrow at 10:00 AM. Please arrive 15 minutes early.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/stream?image=/uploads/images/dr-mohamed-elmogy-67a7b51fbbed1.webp',
        metadata: {
          'doctorName': 'Dr. Ahmed Hassan',
          'appointmentDate': now.add(const Duration(days: 1)).toIso8601String(),
          'appointmentTime': '10:00 AM',
        },
      ),
      NotificationModel(
        id: '2',
        type: NotificationType.appointment,
        title: 'Appointment Confirmed',
        message:
            'Your IVF consultation on Feb 15, 2026 has been confirmed. Location: Bedaya Hospital, Dokki.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        metadata: {
          'appointmentDate': '2026-02-15',
          'location': 'Bedaya Hospital, Dokki',
        },
      ),

      // Medication Notifications
      NotificationModel(
        id: '3',
        type: NotificationType.medication,
        title: 'Time for Your Medication',
        message:
            'It\'s time to take your Follicle Stimulating Hormone injection (150 IU). Don\'t forget!',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        metadata: {
          'medicationName': 'Follicle Stimulating Hormone',
          'dosage': '150 IU',
          'time': '08:00 PM',
        },
      ),
      NotificationModel(
        id: '4',
        type: NotificationType.medication,
        title: 'Medication Reminder',
        message:
            'Remember to take your Progesterone supplement tonight at 9:00 PM.',
        timestamp: now.subtract(const Duration(hours: 18)),
        isRead: true,
        metadata: {'medicationName': 'Progesterone', 'time': '09:00 PM'},
      ),

      // Test Result Notifications
      NotificationModel(
        id: '5',
        type: NotificationType.testResult,
        title: 'Test Results Available',
        message:
            'Your hormone level test results are ready. Tap to view your comprehensive fertility report.',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/stream?image=/uploads/images/HCG_LEVEL__1_-687df47b13c2a.webp',
        metadata: {'testType': 'Hormone Level Test', 'resultStatus': 'ready'},
      ),
      NotificationModel(
        id: '6',
        type: NotificationType.testResult,
        title: 'Blood Test Results',
        message:
            'Your AMH test results show excellent ovarian reserve. Your doctor will discuss details in your next visit.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        metadata: {'testType': 'AMH Test', 'status': 'excellent'},
      ),

      // Treatment Update Notifications
      NotificationModel(
        id: '7',
        type: NotificationType.treatment,
        title: 'Embryo Development Update',
        message:
            'Great news! All 5 embryos are developing well. Day 3 update: Grade A quality. Next update in 2 days.',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/stream?thumbnail=800&image=/uploads/images/IVF_Process-64fefae162634.jpg',
        metadata: {'embryoCount': '5', 'grade': 'A', 'day': '3'},
      ),
      NotificationModel(
        id: '8',
        type: NotificationType.treatment,
        title: 'IVF Cycle Started',
        message:
            'Your IVF treatment cycle has officially begun. Your personalized protocol has been prepared by Dr. Mona Khalil.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        metadata: {'cycleNumber': '1', 'doctorName': 'Dr. Mona Khalil'},
      ),
      NotificationModel(
        id: '9',
        type: NotificationType.treatment,
        title: 'Transfer Day Scheduled',
        message:
            'Your embryo transfer is scheduled for Feb 18, 2026 at 11:00 AM. Please follow pre-transfer instructions.',
        timestamp: now.subtract(const Duration(days: 1, hours: 12)),
        isRead: false,
        metadata: {'transferDate': '2026-02-18', 'transferTime': '11:00 AM'},
      ),

      // Article/Educational Notifications
      NotificationModel(
        id: '10',
        type: NotificationType.article,
        title: 'New Article Published',
        message:
            'Understanding IVF Success Rates: What You Need to Know - Read our latest comprehensive guide.',
        timestamp: now.subtract(const Duration(hours: 12)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/stream?thumbnail=800&image=/uploads/images/IVF_Process-64fefae162634.jpg',
        metadata: {'articleId': '1', 'category': 'IVF Treatment'},
      ),
      NotificationModel(
        id: '11',
        type: NotificationType.educational,
        title: 'Daily Health Tip',
        message:
            'Stay hydrated! Drinking 8-10 glasses of water daily supports cervical mucus production and overall fertility health.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        metadata: {'category': 'Lifestyle'},
      ),
      NotificationModel(
        id: '12',
        type: NotificationType.educational,
        title: 'Fertility Fact',
        message:
            'Did you know? Stress management techniques like meditation can positively impact fertility treatment outcomes.',
        timestamp: now.subtract(const Duration(days: 2, hours: 6)),
        isRead: true,
        metadata: {'category': 'Mental Health'},
      ),

      // Promotional Notifications
      NotificationModel(
        id: '13',
        type: NotificationType.promotional,
        title: '🎉 Special Ramadan Offer',
        message:
            'Get 20% off on comprehensive fertility assessment packages. Limited time offer! Valid until March 15.',
        timestamp: now.subtract(const Duration(hours: 24)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/uploads/images/ismail-abo-alfotouh-673415398a562.webp',
        metadata: {
          'discount': '20%',
          'validUntil': '2026-03-15',
          'offerType': 'Fertility Assessment',
        },
      ),
      NotificationModel(
        id: '14',
        type: NotificationType.promotional,
        title: 'Free Consultation Available',
        message:
            'Book a free initial consultation with our fertility specialists. Limited slots available this month.',
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: true,
        metadata: {'offerType': 'Free Consultation'},
      ),

      // System Notifications
      NotificationModel(
        id: '15',
        type: NotificationType.system,
        title: 'App Updated',
        message:
            'Bedaya Hospital app has been updated with new features including AI-powered fertility analysis!',
        timestamp: now.subtract(const Duration(days: 7)),
        isRead: true,
        metadata: {'version': '2.0.0'},
      ),
      NotificationModel(
        id: '16',
        type: NotificationType.system,
        title: 'Privacy Policy Updated',
        message:
            'We\'ve updated our privacy policy to better protect your data. Please review the changes.',
        timestamp: now.subtract(const Duration(days: 14)),
        isRead: true,
        metadata: {'updateType': 'Privacy Policy'},
      ),

      // More recent notifications
      NotificationModel(
        id: '17',
        type: NotificationType.medication,
        title: 'Medication Stock Alert',
        message:
            'Your Estrogen tablets are running low. You have 3 days left. Consider refilling your prescription.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: false,
        metadata: {'medicationName': 'Estrogen', 'daysLeft': '3'},
      ),
      NotificationModel(
        id: '18',
        type: NotificationType.educational,
        title: 'Nutrition Tip',
        message:
            'Include foods rich in Omega-3 fatty acids in your diet. They help regulate hormones and improve egg quality.',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isRead: false,
        metadata: {'category': 'Nutrition'},
      ),
      NotificationModel(
        id: '19',
        type: NotificationType.appointment,
        title: 'Ultrasound Scan Scheduled',
        message:
            'Your follicle monitoring ultrasound is scheduled for tomorrow at 8:30 AM. Please arrive with a full bladder.',
        timestamp: now.subtract(const Duration(hours: 15)),
        isRead: false,
        metadata: {
          'scanType': 'Follicle Monitoring',
          'appointmentTime': '08:30 AM',
        },
      ),
      NotificationModel(
        id: '20',
        type: NotificationType.treatment,
        title: 'Pregnancy Test Reminder',
        message:
            'It\'s time for your pregnancy test! Please visit the lab tomorrow morning. We\'re hoping for great news! 🤞',
        timestamp: now.subtract(const Duration(minutes: 20)),
        isRead: false,
        imageUrl:
            'https://bedayahospitals.com/stream?thumbnail=800&image=/uploads/images/Blighted_Ovum__1_-685907961de52.webp',
        metadata: {
          'testType': 'Beta HCG',
          'testDate': now.add(const Duration(days: 1)).toIso8601String(),
        },
      ),
    ];
  }

  static List<NotificationModel> getUnreadNotifications() {
    return getNotifications()
        .where((notification) => !notification.isRead)
        .toList();
  }

  static List<NotificationModel> getNotificationsByType(NotificationType type) {
    return getNotifications()
        .where((notification) => notification.type == type)
        .toList();
  }

  static int getUnreadCount() {
    return getUnreadNotifications().length;
  }

  static List<NotificationModel> getTodayNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return getNotifications().where((notification) {
      final notificationDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );
      return notificationDate.isAtSameMomentAs(today);
    }).toList();
  }

  static NotificationModel? getNotificationById(String id) {
    try {
      return getNotifications().firstWhere(
        (notification) => notification.id == id,
      );
    } catch (e) {
      return null;
    }
  }
}
