import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/util/images.dart';

class PermissionHelper {
  static Future<bool> checkLocationPermission({
    bool showDialog = false,
    Location? location,
  }) async {
    location ??= Location();
    PermissionStatus permission = await location.hasPermission();
    if (kDebugMode) {
      print('📍 [PermissionHelper] Current permission: $permission');
      print(
        '📍 [PermissionHelper] Platform: ${GetPlatform.isAndroid ? "Android" : "iOS"}',
      );
    }

    if (permission == PermissionStatus.denied) {
      if (kDebugMode)
        print('📍 [PermissionHelper] Permission denied, requesting...');
      permission = await location.requestPermission();
      if (kDebugMode) print('📍 [PermissionHelper] After request: $permission');
    }
    if (permission == PermissionStatus.deniedForever) {
      if (showDialog) {
        Get.dialog(
          ConfirmationDialogWidget(
            icon: Images.warning,
            description:
                'location_permission_denied_forever'.tr.isNotEmpty
                    ? 'location_permission_denied_forever'.tr
                    : 'Location permission was permanently denied. Please enable it in app settings to continue.',
            onYesPressed: () async {
              await ph.openAppSettings();
              Get.back();
            },
          ),
        );
      }
      return false;
    }

    bool hasValidPermission =
        permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;

    if (kDebugMode) {
      print('📍 [PermissionHelper] Final permission check:');
      print('   - Permission: $permission');
      print('   - Has Valid Permission: $hasValidPermission');
    }

    return hasValidPermission;
  }

  static Future<bool> checkNotificationPermission({
    bool showDialog = false,
  }) async {
    if (kDebugMode) {
      print('🔔 [PermissionHelper] Checking notification permission');
      print(
        '🔔 [PermissionHelper] Platform: ${GetPlatform.isAndroid ? "Android" : "iOS"}',
      );
    }

    ph.PermissionStatus permission = await ph.Permission.notification.status;

    if (kDebugMode) {
      print('🔔 [PermissionHelper] Current permission: $permission');
    }

    if (permission.isDenied) {
      if (kDebugMode)
        print('🔔 [PermissionHelper] Permission denied, requesting...');
      permission = await ph.Permission.notification.request();
      if (kDebugMode) print('🔔 [PermissionHelper] After request: $permission');
    }

    if (permission.isPermanentlyDenied) {
      if (showDialog) {
        Get.dialog(
          ConfirmationDialogWidget(
            icon: Images.warning,
            description:
                'notification_permission_denied_forever'.tr.isNotEmpty
                    ? 'notification_permission_denied_forever'.tr
                    : 'Push notification permission was permanently denied. Please enable it in app settings to receive order updates.',
            onYesPressed: () async {
              await ph.openAppSettings();
              Get.back();
            },
          ),
        );
      }
      return false;
    }

    bool hasValidPermission = permission.isGranted || permission.isLimited;

    if (kDebugMode) {
      print('🔔 [PermissionHelper] Final notification permission check:');
      print('   - Permission: $permission');
      print('   - Has Valid Permission: $hasValidPermission');
    }

    return hasValidPermission;
  }
}
