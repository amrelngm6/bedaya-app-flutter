import 'package:bedaya2/core/models/section_model.dart';

import 'package:bedaya2/core/models/app_remote_config_model.dart';
import 'package:bedaya2/core/models/slide_model.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/services/storage_service.dart';

/// Fetches and caches the public remote app configuration.
///
/// On startup call [loadCached] to populate [current] synchronously from
/// SharedPreferences.  Then call [fetchAndCache] (or let [AppConfigCubit]
/// do it) to refresh from the API and persist the new values.
class AppConfigService extends BaseApiService {
  AppConfigService(super.client, this._storage);

  final StorageService _storage;

  static const _kCacheKey = '_b_app_cfg';

  AppRemoteConfig _current = AppRemoteConfig.defaults;

  /// The last successfully loaded configuration.
  /// Falls back to [AppRemoteConfig.defaults] until something is loaded.
  AppRemoteConfig get current => _current;

  /// Synchronously restores the last cached config from SharedPreferences.
  /// Call once during [ServiceLocator.initialize] so the config is ready
  /// before the first frame is drawn.
  Future<void> loadCached() async {
    final raw = _storage.getString(_kCacheKey);
    if (raw == null) return;
    try {
      _current = AppRemoteConfig.fromJson(raw);
    } catch (_) {
      // Corrupt cache — keep defaults
    }
  }

  /// Fetches the latest configuration from the API, updates [current],
  /// and persists it to SharedPreferences.
  ///
  /// Supports two API response shapes:
  /// - Flat map  — `data: { "app_name": "Bedaya", … }`
  /// - Entry list — `data: [ { "key": "app_name", "value": "Bedaya" }, … ]`
  Future<NetworkResult<AppRemoteConfig>> fetchAndCache() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.appConfig,
    );

    final rawData = response.data?['data'];

    final Map<String, dynamic> map;
    if (rawData is List) {
      // Array of { key, value } entries
      map = {
        for (final entry in rawData.whereType<Map<String, dynamic>>())
          entry['key'] as String: entry['value'],
      };
    } else if (rawData is Map<String, dynamic>) {
      map = rawData;
    } else {
      map = const {};
    }

    final config = AppRemoteConfig.fromMap(map);
    _current = config;
    await _storage.setString(_kCacheKey, config.toJson());
    return config;
  });

  /// Load Sections
  Future<NetworkResult<List<SectionModel>>> fetchSections() =>
      execute(() async {
        final response = await dio.get<Map<String, dynamic>>(
          ApiEndpoints.appSections,
        );

        final rawData = response.data?['data'];
        if (rawData is! List) return [];
        final sections = rawData
            .whereType<Map<String, dynamic>>()
            .map(SectionModel.fromJson)
            .toList();
        return sections;
      });

  /// Load Slides
  Future<NetworkResult<List<SlideModel>>> fetchSlides() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.appSlides,
    );

    final rawData = response.data?['slides'];
    if (rawData is! List) return [];
    final slides = rawData
        .whereType<Map<String, dynamic>>()
        .map(SlideModel.fromJson)
        .toList();
    return slides;
  });
}
