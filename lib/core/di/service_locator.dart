import 'package:bedaya2/core/modules/ai/services/ai_medical_chat_service.dart';
import 'package:bedaya2/core/network/api_client.dart';
import 'package:bedaya2/core/services/storage_service.dart';
import 'package:bedaya2/core/services/app_config_service.dart';
import 'package:bedaya2/core/modules/analytics/services/analytics_service.dart';
import 'package:bedaya2/core/modules/auth/services/auth_service.dart';
import 'package:bedaya2/core/modules/chat/services/chat_service.dart';
import 'package:bedaya2/core/modules/doctors/services/doctor_service.dart';
import 'package:bedaya2/core/modules/bookings/services/booking_service.dart';
import 'package:bedaya2/core/modules/patients/services/patient_service.dart';
import 'package:bedaya2/core/modules/articles/services/article_service.dart';
import 'package:bedaya2/core/modules/services/services/hospital_service.dart';
import 'package:bedaya2/core/modules/notifications/services/notification_api_service.dart';
import 'package:bedaya2/core/modules/notifications/services/push_notification_service.dart';
import 'package:bedaya2/core/modules/paymob/paymob_service.dart';
import 'package:bedaya2/core/modules/medication/services/medication_service.dart';
import 'package:bedaya2/core/modules/medication/services/medication_reminder_service.dart';
import 'package:bedaya2/core/modules/videos/services/video_service.dart';
import 'package:bedaya2/core/modules/ai/services/medical_report_service.dart';
import 'package:bedaya2/core/modules/invoices/services/invoices_service.dart';

/// Application-wide dependency injection container.
///
/// All services are lazily created singletons.  Initialise once in [main]
/// before [runApp]:
/// ```dart
/// await sl.initialize();
/// ```
///
/// Then access services anywhere:
/// ```dart
/// final result = await sl.auth.login(request);
/// ```
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator _instance = ServiceLocator._();

  /// Global accessor – use `sl.auth`, `sl.doctors`, etc.
  static ServiceLocator get instance => _instance;

  bool _initialized = false;

  late final StorageService storage;
  late final ApiClient apiClient;
  late final AppConfigService appConfig;
  late final AnalyticsService analytics;
  late final AuthService auth;
  late final ChatService chat;
  late final DoctorService doctors;
  late final BookingService bookings;
  late final PatientService patient;
  late final ArticleService articles;
  late final HospitalService hospitalServices;
  late final NotificationApiService notifications;
  late final PushNotificationService pushNotifications;
  late final MedicationService medications;
  late final MedicationReminderService medicationReminders;
  late final VideoService videos;
  late final MedicalReportService medicalReports;
  late final AIMedicalChatService aiMedicalChat;
  late final InvoicesService invoices;
  late final PaymobApiService paymob;

  /// Must be called once before any service is accessed.
  Future<void> initialize() async {
    if (_initialized) return;

    storage = await StorageService.create();
    ApiClient.init(storage);
    apiClient = ApiClient.instance;

    appConfig = AppConfigService(apiClient, storage);
    await appConfig.loadCached();

    analytics = AnalyticsService(apiClient);
    await analytics.initialize();

    auth = AuthService(apiClient, storage);
    chat = ChatService(apiClient);
    doctors = DoctorService(apiClient);
    bookings = BookingService(apiClient);
    patient = PatientService(apiClient);
    articles = ArticleService(apiClient);
    hospitalServices = HospitalService(apiClient);
    notifications = NotificationApiService(apiClient);
    pushNotifications = PushNotificationService(
      notificationApiService: notifications,
    );
    medications = MedicationService(apiClient);
    medicationReminders = MedicationReminderService();
    await medicationReminders.initialize();
    videos = VideoService(apiClient);
    medicalReports = MedicalReportService(apiClient);
    aiMedicalChat = AIMedicalChatService(apiClient);
    invoices = InvoicesService(apiClient);
    paymob = PaymobApiService(apiClient);

    _initialized = true;
  }
}

/// Top-level shorthand so callers can write `sl.auth` instead of
/// `ServiceLocator.instance.auth`.
final sl = ServiceLocator.instance;
