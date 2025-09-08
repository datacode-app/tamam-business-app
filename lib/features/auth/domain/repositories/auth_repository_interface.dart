// Dart imports:
import 'dart:async';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/business/domain/models/package_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class AuthRepositoryInterface implements RepositoryInterface {
  Future<dynamic> login(String? email, String password, String type);
  Future<dynamic> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover);
  Future<dynamic> updateToken();
  Future<bool> saveUserToken(String token, String zoneTopic, String type);
  String getUserToken();
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<void> saveUserNumberAndPassword(String number, String password, String type);
  String getUserNumber();
  String getUserPassword();
  String getUserType();
  bool isNotificationActive();
  Future<void> setNotificationActive(bool isActive);
  Future<bool> clearUserNumberAndPassword();
  Future<dynamic> toggleStoreClosedStatus();
  Future<bool> saveIsStoreRegistration(bool status);
  bool getIsStoreRegistration();
  String getModuleType();
  void setModuleType(String type);
  Future<PackageModel?> getPackageList({int? moduleId});
}
