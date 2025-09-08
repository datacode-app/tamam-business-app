import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tamam_business/features/auth/controllers/auth_controller.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';

/// Local Development Authentication Helper
/// 
/// This helper automatically logs in with test credentials during local development
/// to prevent getting stuck on the sign-in screen during development.
/// 
/// ⚠️ IMPORTANT: This should only be used in local development!
class LocalAuthHelper {
  // Test vendor credentials for local development
  static const String testEmail = 'vendor@test.com';
  static const String testPassword = 'password';
  static const String testVendorType = 'owner';
  
  /// Automatically log in with test credentials during local development
  static Future<void> autoLoginForDevelopment() async {
    // Only run in debug mode and when not already logged in
    if (!kDebugMode) return;
    
    try {
      final authController = Get.find<AuthController>();
      final splashController = Get.find<SplashController>();
      
      // Check if already logged in
      if (authController.isLoggedIn()) {
        if (kDebugMode) {
          print('====> LocalAuth: Already logged in, skipping auto-login');
        }
        return;
      }
      
      // Check if config is loaded first
      if (splashController.configModel == null) {
        if (kDebugMode) {
          print('====> LocalAuth: Config not loaded yet, waiting...');
        }
        await Future.delayed(const Duration(seconds: 2));
        if (splashController.configModel == null) {
          if (kDebugMode) {
            print('====> LocalAuth: Config still not loaded, skipping auto-login');
          }
          return;
        }
      }
      
      if (kDebugMode) {
        print('====> LocalAuth: Attempting auto-login with test credentials');
        print('====> LocalAuth: Email: $testEmail');
      }
      
      // Attempt login
      await authController.login(testEmail, testPassword, testVendorType);
      
      if (authController.isLoggedIn()) {
        if (kDebugMode) {
          print('====> LocalAuth: ✅ Auto-login successful!');
        }
      } else {
        if (kDebugMode) {
          print('====> LocalAuth: ❌ Auto-login failed');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('====> LocalAuth: Error during auto-login: $e');
      }
    }
  }
  
  /// Check if the current environment supports auto-login
  static bool shouldAttemptAutoLogin() {
    if (!kDebugMode) return false;
    
    try {
      final authController = Get.find<AuthController>();
      return !authController.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
  
  /// Display development login hint on sign-in screen
  static void showDevelopmentHint() {
    if (!kDebugMode) return;
    
    if (kDebugMode) {
      print('='.padRight(50, '='));
      print('🧪 DEVELOPMENT MODE - Auto Login Available');
      print('Test Credentials:');
      print('  Email: $testEmail');
      print('  Password: $testPassword');
      print('  Type: $testVendorType');
      print('='.padRight(50, '='));
    }
  }
}