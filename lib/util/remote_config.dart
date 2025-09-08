import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  static RemoteConfigService? _instance;

  // Keys for remote config values
  static const String keyBackendBaseUrl = 'backend_base_url';
  static const String keyIsUnderReview = 'is_under_review';
  static const String keyEnableVendorRegistration = 'enable_vendor_registration';

  RemoteConfigService._(this._remoteConfig);

  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.setDefaults({
        keyBackendBaseUrl: 'https://admin.tamam.shop',
        keyIsUnderReview: false,
        keyEnableVendorRegistration: false, // Default to false for Apple App Store compliance
      });

      await remoteConfig.fetchAndActivate();
      _instance = RemoteConfigService._(remoteConfig);
    }
    return _instance!;
  }

  String get backendBaseUrl => _remoteConfig.getString(keyBackendBaseUrl);
  bool get isUnderReview => _remoteConfig.getBool(keyIsUnderReview);
  
  /// Controls whether vendor registration features are enabled
  /// Set to false for Apple App Store to comply with guideline 3.1.1
  /// Set to true for Google Play Store and other distributions
  bool get enableVendorRegistration => _remoteConfig.getBool(keyEnableVendorRegistration);

  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote config refreshed successfully');
      debugPrint('Vendor registration enabled: $enableVendorRegistration');
    } catch (e) {
      debugPrint('Error refreshing remote config: $e');
    }
  }
}
