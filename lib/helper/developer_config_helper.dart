import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamam_business/helper/remote_config_helper.dart';

class DeveloperConfigHelper {
  static const String _devModeKey = 'tamam_dev_mode_enabled';
  static const String _tapCountKey = 'tamam_logo_tap_count';
  static const String _lastTapTimeKey = 'tamam_last_tap_time';

  // Reset tap count after 5 seconds of inactivity
  static const int tapResetSeconds = 5;
  static const int requiredTaps = 9;

  /// Check if developer mode is enabled
  static Future<bool> isDeveloperModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_devModeKey) ?? false;
  }

  /// Enable or disable developer mode
  static Future<void> setDeveloperMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, enabled);

    if (kDebugMode) {
      debugPrint(
        '🔧 [TamamBusiness] Developer mode ${enabled ? 'ENABLED' : 'DISABLED'}',
      );
    }
  }

  /// Handle logo tap and check if developer mode should be activated
  static Future<bool> handleLogoTap() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTapTime = prefs.getInt(_lastTapTimeKey) ?? 0;
    final currentTapCount = prefs.getInt(_tapCountKey) ?? 0;

    // Reset tap count if too much time has passed
    int newTapCount = 1;
    if (now - lastTapTime < tapResetSeconds * 1000) {
      newTapCount = currentTapCount + 1;
    }

    await prefs.setInt(_tapCountKey, newTapCount);
    await prefs.setInt(_lastTapTimeKey, now);

    // Activate developer mode after required taps
    if (newTapCount >= requiredTaps) {
      debugPrint(
        '🎯 [TamamBusiness] Logo tapped $requiredTaps times - Activating Developer Mode!',
      );
      await setDeveloperMode(true);
      await prefs.setInt(_tapCountKey, 0); // Reset counter
      return true;
    } else {
      debugPrint(
        '🎯 [TamamBusiness] Logo tap count: $newTapCount/$requiredTaps',
      );
    }

    return false;
  }

  /// Get the appropriate backend URL based on developer mode
  static Future<String> getEffectiveBackendUrl() async {
    // In debug builds, force staging URL regardless of remote config
    if (kDebugMode) {
      return 'https://admin-stag.tamam.krd';
    }
    final isDevMode = await isDeveloperModeEnabled();

    if (isDevMode) {
      // Use development URL when developer mode is active
      final devUrl = RemoteConfigHelper.getBackendBaseUrlDev();
      debugPrint(
        '🌐 [TamamBusiness] Developer mode ACTIVE - Using DEV URL: $devUrl',
      );
      return devUrl;
    } else {
      // Use regular production URL
      final prodUrl = RemoteConfigHelper.getBackendBaseUrl();
      debugPrint(
        '🌐 [TamamBusiness] Developer mode INACTIVE - Using PROD URL: $prodUrl',
      );
      return prodUrl;
    }
  }

  /// Reset developer mode (for testing)
  static Future<void> resetDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devModeKey);
    await prefs.remove(_tapCountKey);
    await prefs.remove(_lastTapTimeKey);

    if (kDebugMode) {
      debugPrint('🔄 Developer mode reset');
    }
  }

  /// Show developer options dialog
  static Map<String, String> getDeveloperOptions() {
    return {
      'Production URL': RemoteConfigHelper.getBackendBaseUrl(),
      'Backup URL': RemoteConfigHelper.getBackendBaseUrl2(),
      'Development URL': RemoteConfigHelper.getBackendBaseUrlDev(),
    };
  }

  /// Get developer status info
  static Future<Map<String, dynamic>> getDeveloperStatus() async {
    final isDevMode = await isDeveloperModeEnabled();
    final effectiveUrl = await getEffectiveBackendUrl();

    return {
      'developer_mode': isDevMode,
      'effective_url': effectiveUrl,
      'available_urls': getDeveloperOptions(),
      'remote_config_values': RemoteConfigHelper.getAllValues(),
    };
  }
}
