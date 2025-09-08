// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/auth/controllers/auth_controller.dart';
import 'package:tamam_business/helper/route_helper.dart';

class ApiChecker {
  static bool _isHandling401 = false; // Prevent multiple 401 handlers
  
  static void checkApi(Response response) {
    if(response.statusCode == 401) {
      // Prevent infinite loop by checking if we're already handling a 401
      if (_isHandling401) {
        if (kDebugMode) {
          print('====> 401 handler already active, skipping to prevent loop');
        }
        return;
      }
      
      _isHandling401 = true;
      
      if (kDebugMode) {
        print('====> 401 Unauthorized - Clearing session and redirecting to login');
      }
      
      try {
        Get.find<AuthController>().clearSharedData();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      } finally {
        // Reset flag after a delay to allow for cleanup
        Future.delayed(const Duration(seconds: 2), () {
          _isHandling401 = false;
        });
      }
    }else {
      showCustomSnackBar(response.statusText);
    }
  }
}
