/// All API endpoint paths relative to [AppConfig.apiBaseUrl].
///
/// Use the static methods for dynamic segments (e.g. [doctorById]).
/// Never hard-code endpoint strings in service classes – always reference
/// this file so changes propagate everywhere automatically.
abstract final class ApiEndpoints {
  // ─── Authentication ─────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String checkPhoneExists = '/auth/check-phone-exists';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/account/change-password';
  static const String myProfile = '/account/profile';
  static const String updateProfile = '/account/profile';
  static const String updateAvatar = '/account/profile/avatar';
  static const String appSlides = '/home/slides';
  static const String logout = '/account/logout';

  // ─── Analytics & sessions ───────────────────────────────────────────────
  static const String analyticsStartSession = '/analytics/sessions/start';
  static String analyticsEndSession(Object sessionId) =>
      '/analytics/sessions/$sessionId/end';
  static String analyticsUpdatePushToken(Object sessionId) =>
      '/analytics/sessions/$sessionId/push-token';
  static const String analyticsSendEventsBulk = '/analytics/events/batch';
  static const String analyticsSendEvent = '/sessions/analytics/events';

  // ─── Doctors ────────────────────────────────────────────────────────────────
  static const String doctors = '/doctors';
  static const String doctorCategories = '/doctors/categories';
  static const String guestDoctors = '/guest/doctors';
  static const String guestDoctorCategories = '/guest/doctors/categories';
  static String doctorById(Object id) => '/doctors/$id';
  static String guestDoctorById(Object id) => '/guest/doctors/$id';
  static String likeDoctorById(Object id) => '/doctors/$id/like';
  static String doctorAvailability(Object doctorId, Object date) =>
      '/doctors/$doctorId/availability?scheduled_date=$date&doctor_id=$doctorId';
  static String doctorReviews(Object doctorId) => '/doctors/$doctorId/reviews';
  static String doctorWorkingHours(Object doctorId) =>
      '/doctors/$doctorId/working-hours';

  // ─── Appointments / Bookings ─────────────────────────────────────────────────
  static const String bookings = '/bookings';
  static String bookingById(Object id) => '/bookings/$id';
  static String cancelBooking(Object id) => '/bookings/$id/cancel';
  static String rescheduleBooking(Object id) => '/bookings/$id/reschedule';
  static String slotsForDay(Object id, Object day) =>
      '/bookings/available-slots?scheduled_date=$day&doctor_id=$id';

  // ─── Hospital Services ───────────────────────────────────────────────────────
  static const String services = '/services';
  static String serviceById(Object id) => '/services/$id';

  // ─── NLP AI chat ─────────────────────────────────────────────────────────────
  static const String aiMedicalChatSendText = '/nlp/process-text';
  static const String aiMedicalChatHistory = '/nlp/chat-history';

  // ─── Invoices ─────────────────────────────────────────────────────────────────
  static const String invoices = '/invoices';
  static String invoiceById(Object id) => '/invoices/show/$id';
  static String getPaymentUrl(Object id) => '/invoices/payment-url/$id';
  static const String addInvoiceTransaction = '/invoices/transaction';
  static const String paymobCreateIntention = '/payments/paymob/intention';

  // ─── Articles ────────────────────────────────────────────────────────────────
  static const String articles = '/articles';
  static const String guestArticles = '/guest/articles';
  static String articleById(Object id) => '/articles/$id/show';
  static String likeArticle(Object id) => '/articles/$id/like';

  // ─── Videos ────────────────────────────────────────────────────────────────
  static const String videos = '/videos';
  static const String guestVideos = '/guest/videos';
  static String videoById(Object id) => '/videos/$id';
  static String likeVideo(Object id) => '/videos/$id/like';
  static String addVideoComment(Object id) => '/videos/$id/comment';
  static String videoComments(Object id) => '/videos/$id/comments';

  // ─── Patient ─────────────────────────────────────────────────────────────────
  static const String patientProfile = '/patient/profile';
  static const String patientMedicalRecords = '/patient/medical-records';
  static const String patientAppointments = '/patient/appointments';
  static const String patientReports = '/patient/reports';
  static String patientReportById(Object id) => '/patient/reports/$id';

  // ─── Medical Profile (Conditions) ────────────────────────────────────────
  static const String medicalProfileConditions = '/medical-conditions';
  static String medicalProfileConditionById(Object id) =>
      '/medical-conditions/$id';

  // ──── Medical Reports ────────────────────────────────────────────────────────
  static const String medicalReportsTests = '/medical-reports/tests';
  static const String medicalReportsStatistics = '/medical-reports/statistics';
  static const String medicalReports = '/medical-reports';
  static String medicalReportById(Object id) => '/medical-reports/$id';

  // ─── Notifications ───────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationById(Object id) => '/notifications/$id';
  static String markNotificationRead(Object id) =>
      '/notifications/$id/mark-read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';

  // ─── Device / Push Notifications ─────────────────────────────────────────────
  static const String registerFcmToken = '/device-tokens/register';
  static const String unregisterFcmToken = '/device-tokens/unregister';

  // ─── Chat ───────────────────────────────────────────────────────────
  static const String chatConversations = '/chat/conversations';
  static String chatConversationById(Object id) => '/chat/conversations/$id';
  static String chatConversationMessages(Object id) =>
      '/chat/conversations/$id/messages';
  static String checkNewMessages(Object id, Object lastMessageId) =>
      '/chat/conversations/$id/new-messages?last_message_id=$lastMessageId';
  static String setMessagesRead(Object id) => '/chat/conversations/$id/read';
  static const String unredMessagesCount = '/chat/unread-count';

  /// ─── App Config ────────────────────────────────────────────────
  static const String appConfig = '/app/settings';
  static const String appSections = '/app/sections';

  /// ─── Medications ────────────────────────────────────────────────
  static const String patientMedications = '/medications';
  static String patientMedicationById(Object id) => '/medications/$id';
  static String takeMedicationById(Object id) => '/medications/$id/take';
  static const String medicationCatalog = '/medications/catalog';
  static const String activeMedications = '/medications/active';
  static const String medicationStatistics = '/medications/statistics';
}
