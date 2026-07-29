import 'package:bedaya2/core/models/app_remote_config_model.dart';
import 'package:bedaya2/presentation/widgets/main-navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedaya2/core/config/app_config.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/notifications/services/push_notification_service.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/config/firebase_options.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/app_config_cubit.dart';
import 'package:bedaya2/core/modules/auth/presentation/cubits/auth_cubit.dart';
import 'package:bedaya2/presentation/pages/force_update_page.dart';
import 'package:bedaya2/presentation/pages/maintenance_page.dart';
import 'package:bedaya2/core/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:bedaya2/presentation/pages/onboarding_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await EasyLocalization.ensureInitialized();

  final location = tz.getLocation('Africa/Cairo');
  tz.setLocalLocation(location);

  // ── Firebase ────────────────────────────────────────────────────────────────
  // Replace firebase_options.dart with the output of `flutterfire configure`.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register the background message handler BEFORE calling sl.initialize().
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await sl.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(sl.analytics);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(sl.analytics);
    super.dispose();
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Read once from the service — already populated from cache by sl.initialize()
    final initialConfig = sl.appConfig.current;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => AppConfigCubit(sl.appConfig)..loadConfig()),
      ],
      child: MaterialApp(
        title: initialConfig.appName ?? 'Bedaya Hospital',
        debugShowCheckedModeBanner: false,
        navigatorKey: PushNotificationService.navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // Theme is built from the cached initial config so the first frame
        // already reflects the server-side primary colour.
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: initialConfig.primaryColor,
          ),
          useMaterial3: true,
          fontFamily: context.locale == const Locale('en')
              ? GoogleFonts.poppins().fontFamily
              : GoogleFonts.cairo().fontFamily,
        ),
        // The builder layer reacts to config changes (maintenance / force-update
        // / theme) without rebuilding the MaterialApp itself.
        builder: (context, child) {
          return BlocBuilder<AppConfigCubit, AppConfigState>(
            buildWhen: (prev, curr) {
              // Only rebuild when meaningful config fields change
              final a = _cubitConfig(prev);
              final b = _cubitConfig(curr);
              return a.maintenanceMode != b.maintenanceMode ||
                  a.forceUpdateEnabled != b.forceUpdateEnabled ||
                  a.primaryColor != b.primaryColor;
            },
            builder: (ctx, state) {
              final config = ctx.read<AppConfigCubit>().current;

              // ── Maintenance gate ────────────────────────────────────────
              if (config.maintenanceMode) {
                return const MaintenancePage();
              }

              // ── Force update gate ───────────────────────────────────────
              if (config.forceUpdateEnabled &&
                  AppConfig.isVersionBehind(config.minAppVersion)) {
                return const ForceUpdatePage();
              }

              // ── Apply dynamic theme ─────────────────────────────────────
              return Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: config.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
        },
        routes: {'/notifications': (_) => const NotificationsPage()},
        home: FutureBuilder<bool>(
          future: _checkFirstLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryTeal,
                  ),
                ),
              );
            }
            final hasSeenOnboarding = snapshot.data ?? false;
            return hasSeenOnboarding
                ? const MainNavigationPage()
                : const OnboardingPage();
          },
        ),
      ),
    );
  }

  // Safely extracts the config from any state variant.
  static AppRemoteConfig _cubitConfig(AppConfigState state) => switch (state) {
    AppConfigLoaded(:final config) => config,
    AppConfigLoading(:final cached) => cached,
    AppConfigError(:final config) => config,
    AppConfigInitial() => AppRemoteConfig.defaults,
  };
}
