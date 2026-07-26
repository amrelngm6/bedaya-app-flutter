import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bedaya2/core/models/app_remote_config_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/services/app_config_service.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class AppConfigState {
  const AppConfigState();
}

/// Initial state before any load has been triggered.
final class AppConfigInitial extends AppConfigState {
  const AppConfigInitial();
}

/// A network fetch is in progress; [cached] is the last known config.
final class AppConfigLoading extends AppConfigState {
  final AppRemoteConfig cached;
  const AppConfigLoading(this.cached);
}

/// Config has been loaded successfully from the API.
final class AppConfigLoaded extends AppConfigState {
  final AppRemoteConfig config;
  const AppConfigLoaded(this.config);
}

/// The API fetch failed; [config] holds the last known good config.
final class AppConfigError extends AppConfigState {
  final AppRemoteConfig config;
  final String message;
  const AppConfigError({required this.config, required this.message});
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

/// Manages the lifecycle of [AppRemoteConfig].
///
/// Usage:
/// ```dart
/// BlocProvider(create: (_) => AppConfigCubit(sl.appConfig)..loadConfig())
/// ```
///
/// Then in any widget:
/// ```dart
/// final config = context.read<AppConfigCubit>().current;
/// ```
class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit(this._service) : super(const AppConfigInitial());

  final AppConfigService _service;

  /// The best available config regardless of loading state.
  AppRemoteConfig get current => switch (state) {
    AppConfigLoaded(:final config) => config,
    AppConfigLoading(:final cached) => cached,
    AppConfigError(:final config) => config,
    AppConfigInitial() => _service.current,
  };

  /// Fetches the latest config from the API.
  ///
  /// Emits [AppConfigLoading] immediately (with the cached value), then
  /// [AppConfigLoaded] or [AppConfigError] when the request completes.
  Future<void> loadConfig() async {
    emit(AppConfigLoading(_service.current));
    final result = await _service.fetchAndCache();
    switch (result) {
      case Success(:final data):
        emit(AppConfigLoaded(data));
      case Failure(:final exception):
        emit(
          AppConfigError(config: _service.current, message: exception.message),
        );
    }
  }
}
