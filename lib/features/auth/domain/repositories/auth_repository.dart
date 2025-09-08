// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:tamam_business/features/business/domain/models/package_model.dart';
import 'package:tamam_business/util/app_constants.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> login(String? email, String password, String type) async {
    return await apiClient.postData(AppConstants.loginUri, {"email": email, "password": password, 'vendor_type': type}, handleError: false);
  }

  @override
  Future<Response> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover) async {
    return await apiClient.postMultipartData(AppConstants.restaurantRegisterUri, data, [MultipartBody('logo', logo), MultipartBody('cover_photo', cover)]);
  }

  @override
  Future<Response> updateToken() async {
    // Check if user is logged in before attempting token update
    String currentToken = getUserToken();
    if (currentToken.isEmpty) {
      if (kDebugMode) {
        print('====> FCM Update: No user token available, skipping');
      }
      return const Response(statusCode: 401, statusText: 'No user token available');
    }

    String? deviceToken;
    if (GetPlatform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false,
        criticalAlert: false, provisional: false, sound: true,
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        deviceToken = await _saveDeviceToken();
      }
    }else {
      deviceToken = await _saveDeviceToken();
    }
    
    if(!GetPlatform.isWeb) {
      try {
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
        String? zoneTopic = sharedPreferences.getString(AppConstants.zoneTopic);
        if (zoneTopic != null && zoneTopic.isNotEmpty) {
          FirebaseMessaging.instance.subscribeToTopic(zoneTopic);
        }
      } catch (e) {
        if (kDebugMode) {
          print('====> FCM subscription error (ignored): $e');
        }
      }
    }
    
    return await apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": currentToken, "fcm_token": deviceToken}, handleError: false);
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '';
    if(!GetPlatform.isWeb) {
      deviceToken = (await FirebaseMessaging.instance.getToken())!;
    }
    if (kDebugMode) {
      print('-----Device Token----- $deviceToken');
    }
    return deviceToken;
  }

  @override
  Future<bool> saveUserToken(String token, String zoneTopic, String type) async {
    apiClient.updateHeader(token, sharedPreferences.getString(AppConstants.languageCode), null, type);
    sharedPreferences.setString(AppConstants.zoneTopic, zoneTopic);
    sharedPreferences.setString(AppConstants.type, type);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  @override
  Future<bool> clearSharedData() async {
    if(!GetPlatform.isWeb) {
      // Only attempt FCM token cleanup if we have a valid token to begin with
      // This prevents infinite loops when 401 errors trigger clearSharedData
      String currentToken = getUserToken();
      if (currentToken.isNotEmpty) {
        try {
          // Use handleError: false to prevent 401 loops, and don't await to avoid blocking logout
          apiClient.postData(AppConstants.tokenUri, {"_method": "put", "token": currentToken, "fcm_token": '@'}, handleError: false);
        } catch (e) {
          // Ignore errors during cleanup - we're logging out anyway
          if (kDebugMode) {
            print('====> FCM cleanup error during logout (ignored): $e');
          }
        }
      }
      
      // Unsubscribe from topics
      try {
        String? zoneTopic = sharedPreferences.getString(AppConstants.zoneTopic);
        if (zoneTopic != null && zoneTopic.isNotEmpty) {
          FirebaseMessaging.instance.unsubscribeFromTopic(zoneTopic);
        }
      } catch (e) {
        if (kDebugMode) {
          print('====> Topic unsubscribe error during logout (ignored): $e');
        }
      }
    }
    
    // Clear shared preferences
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.remove(AppConstants.userAddress);
    await sharedPreferences.remove(AppConstants.type);
    await sharedPreferences.remove(AppConstants.moduleType);
    return true;
  }

  @override
  Future<void> saveUserNumberAndPassword(String number, String password, String type) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(AppConstants.userNumber, number);
      await sharedPreferences.setString(AppConstants.userType, type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  @override
  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  @override
  String getUserType() {
    return sharedPreferences.getString(AppConstants.type) ?? "";
  }

  @override
  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  @override
  Future<void> setNotificationActive(bool isActive) async{
    if(isActive) {
      await updateToken(); // Fixed: Added missing await
    }else {
      if(!GetPlatform.isWeb) {
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
        FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString(AppConstants.zoneTopic)!);
      }
    }
    sharedPreferences.setBool(AppConstants.notification, isActive);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userType);
    await sharedPreferences.remove(AppConstants.userPassword);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  Future<bool> toggleStoreClosedStatus() async {
    Response response = await apiClient.postData(AppConstants.updateVendorStatusUri, {});
    return (response.statusCode == 200);
  }

  @override
  Future<bool> saveIsStoreRegistration(bool status) async {
    return await sharedPreferences.setBool(AppConstants.isStoreRegister, status);
  }

  @override
  bool getIsStoreRegistration() {
    return sharedPreferences.getBool(AppConstants.isStoreRegister) ?? false;
  }

  @override
  Future<PackageModel?> getPackageList({int? moduleId}) async {
    PackageModel? packageModel;
    Response response = await apiClient.getData('${AppConstants.restaurantPackagesUri}?module_id=$moduleId');
    if(response.statusCode == 200) {
      packageModel = PackageModel.fromJson(response.body);
    }
    return packageModel;
  }

  @override
  String getModuleType() {
    return sharedPreferences.getString(AppConstants.moduleType) ?? "";
  }

  @override
  void setModuleType(String type) {
    sharedPreferences.setString(AppConstants.moduleType, type);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

}
