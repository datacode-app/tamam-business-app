// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/auth/domain/services/auth_service_interface.dart';
import 'package:tamam_business/features/business/controllers/business_controller.dart';
import 'package:tamam_business/features/business/domain/models/package_model.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/features/profile/domain/models/profile_model.dart';
import 'package:tamam_business/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/helper/route_helper.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _notification = true;
  bool get notification => _notification;

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  XFile? _pickedCover;
  XFile? get pickedCover => _pickedCover;

  final List<String?> _deliveryTimeTypeList = ['minute', 'hours', 'days'];
  List<String?> get deliveryTimeTypeList => _deliveryTimeTypeList;

  int _deliveryTimeTypeIndex = 0;
  int get deliveryTimeTypeIndex => _deliveryTimeTypeIndex;

  int _vendorTypeIndex = 0;
  int get vendorTypeIndex => _vendorTypeIndex;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  double _storeStatus = 0.1;
  double get storeStatus => _storeStatus;

  String _storeMinTime = '--';
  String get storeMinTime => _storeMinTime;

  String _storeMaxTime = '--';
  String get storeMaxTime => _storeMaxTime;

  String _storeTimeUnit = 'minute';
  String get storeTimeUnit => _storeTimeUnit;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  String? _subscriptionType;
  String? get subscriptionType => _subscriptionType;

  String? _expiredToken;
  String? get expiredToken => _expiredToken;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  Future<ResponseModel?> login(
      String? email, String password, String type) async {
    _isLoading = true;
    update();
    Response response = await authServiceInterface.login(email, password, type);
    ResponseModel? responseModel =
        await authServiceInterface.manageLogin(response, type);
    _isLoading = false;
    update();
    return responseModel;
  }

  void pickImageForReg(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
      update();
    } else {
      // Prevent multiple simultaneous calls
      if (_isLoading) {
        debugPrint('Image picker already in progress, ignoring tap');
        return;
      }
      
      debugPrint('Starting image picker for ${isLogo ? 'logo' : 'cover'}');
      _isLoading = true;
      update();
      
      try {
        // Platform-specific permission handling
        if (kIsWeb) {
          // Web doesn't need permission requests
          debugPrint('Web platform - no permission request needed');
          await _openImagePicker(isLogo);
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          debugPrint('iOS platform - requesting photo library permission');
          PermissionStatus status = await Permission.photos.request();
          debugPrint('Permission status: $status');

          if (status.isGranted || status.isLimited) {
            debugPrint('Permission granted, opening image picker');
            await _openImagePicker(isLogo);
          } else if (status.isPermanentlyDenied) {
            debugPrint('Permission permanently denied - showing settings dialog');
            _showPermissionDeniedDialog();
          } else {
            debugPrint('Permission denied');
            showCustomSnackBar('Photo library access is required to select an image.');
          }
        } else {
          // Android - use direct image picker (it handles permissions automatically)
          debugPrint('Android platform - using direct image picker');
          await _openImagePicker(isLogo);
        }
      } catch (e) {
        // Handle any errors during image picking
        debugPrint('Image picker error: $e');
        showCustomSnackBar('Error selecting image. Please try again.');
      } finally {
        debugPrint('Image picker process finished');
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> _openImagePicker(bool isLogo) async {
    try {
      debugPrint('Opening image picker');
      
      // Ensure any open dialogs are closed first
      if (Get.isDialogOpen == true) {
        debugPrint('Closing existing dialog before opening image picker');
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Ensure any open bottom sheets are closed
      if (Get.isBottomSheetOpen == true) {
        debugPrint('Closing existing bottom sheet before opening image picker');
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Add a small delay to ensure UI is stable
      await Future.delayed(const Duration(milliseconds: 100));
      
      XFile? pickImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image quality to reduce size
        maxWidth: 1920,
        maxHeight: 1080,
      );
      debugPrint('Image picker result: ${pickImage?.path ?? 'null'}');

      if (pickImage != null) {
        // Check file size (2MB limit)
        int imageSize = await pickImage.length();
        debugPrint('Image size: $imageSize bytes');
        if (imageSize > 2000000) {
          showCustomSnackBar('please_upload_lower_size_file'.tr);
          return;
        }

        // Assign the picked image
        if (isLogo) {
          _pickedLogo = pickImage;
          debugPrint('Logo image set');
        } else {
          _pickedCover = pickImage;
          debugPrint('Cover image set');
        }
      } else {
        debugPrint('User cancelled image selection');
      }
    } catch (e) {
      debugPrint('Image picker exception: $e');
      // Check if it's a platform exception (common on iOS simulator)
      if (e is PlatformException) {
        if (e.code == 'photo_access_denied') {
          showCustomSnackBar('Photo library access denied. Please enable in Settings.');
        } else if (e.code == 'camera_access_denied') {
          showCustomSnackBar('Camera access denied. Please enable in Settings.');
        } else if (e.code == 'invalid_image') {
          showCustomSnackBar('Invalid image selected. Please choose a different image.');
        } else {
          showCustomSnackBar('Error selecting image: ${e.message ?? 'Unknown error'}');
        }
      } else {
        showCustomSnackBar('Error selecting image. Please try again.');
      }
    }
  }

  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Photo access is required to upload images. Please enable photo access in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Track FCM token update attempts to prevent infinite loops
  int _fcmUpdateAttempts = 0;
  DateTime? _lastFcmUpdateAttempt;
  static const int _maxFcmAttempts = 3;
  static const Duration _fcmCooldownPeriod = Duration(minutes: 5);

  Future<void> updateToken() async {
    try {
      // Circuit breaker: Prevent infinite loops
      final now = DateTime.now();
      if (_lastFcmUpdateAttempt != null && 
          now.difference(_lastFcmUpdateAttempt!) < _fcmCooldownPeriod) {
        if (_fcmUpdateAttempts >= _maxFcmAttempts) {
          if (kDebugMode) {
            print('====> FCM Update: Circuit breaker active, too many attempts');
          }
          return;
        }
      } else {
        // Reset counter after cooldown period
        _fcmUpdateAttempts = 0;
      }

      // Check if user is actually logged in before attempting FCM update
      if (!authServiceInterface.isLoggedIn()) {
        if (kDebugMode) {
          print('====> FCM Update: User not logged in, skipping');
        }
        return;
      }

      _fcmUpdateAttempts++;
      _lastFcmUpdateAttempt = now;
      
      if (kDebugMode) {
        print('====> FCM Update: Attempt $_fcmUpdateAttempts/$_maxFcmAttempts');
      }

      await authServiceInterface.updateToken();
      
      // Success - reset counter
      _fcmUpdateAttempts = 0;
      
    } catch (e) {
      if (kDebugMode) {
        print('====> FCM Update Error: $e');
      }
      // Don't rethrow - let the app continue without FCM update
    }
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  void storeStatusChange(double value, {bool isUpdate = true}) {
    _storeStatus = value;
    if (isUpdate) {
      update();
    }
  }

  void minTimeChange(String time) {
    _storeMinTime = time;
    update();
  }

  void maxTimeChange(String time) {
    _storeMaxTime = time;
    update();
  }

  void timeUnitChange(String unit) {
    _storeTimeUnit = unit;
    update();
  }

  void changeVendorType(int index, {bool isUpdate = true}) {
    _vendorTypeIndex = index;
    if (isUpdate) {
      update();
    }
  }

  Future<bool> clearSharedData() async {
    Get.find<SplashController>().setModule(null, null);
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password, String type) {
    authServiceInterface.saveUserNumberAndPassword(number, password, type);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  String getUserType() {
    return authServiceInterface.getUserType();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  Future<void> toggleStoreClosedStatus() async {
    bool isSuccess = await authServiceInterface.toggleStoreClosedStatus();
    if (isSuccess) {
      if (getModuleType() == 'rental') {
        await Get.find<TaxiProfileController>().getProfile();
      } else {
        Get.find<ProfileController>().getProfile();
      }
    }
    update();
  }

  Future<void> registerStore(Map<String, String> data) async {
    _isLoading = true;
    update();

    Response response = await authServiceInterface.registerRestaurant(
        data, _pickedLogo, _pickedCover);

    if (response.statusCode == 200) {
      int? storeId = response.body['store_id'];
      int? packageId = response.body['package_id'];

      if (packageId == null) {
        Get.find<BusinessController>()
            .submitBusinessPlan(storeId: storeId!, packageId: null);
      } else {
        Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(
            storeId: storeId, packageId: packageId));
      }
    }

    _isLoading = false;
    update();
  }

  void setDeliveryTimeTypeIndex(String? type, bool notify) {
    _deliveryTimeTypeIndex = _deliveryTimeTypeList.indexOf(type);
    if (notify) {
      update();
    }
  }

  void showHidePass({bool isUpdate = true}) {
    _showPassView = !_showPassView;
    if (isUpdate) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if (pass.length > 7) {
      _lengthCheck = true;
    }
    if (pass.contains(RegExp(r'[a-z]'))) {
      _lowercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[A-Z]'))) {
      _uppercaseCheck = true;
    }
    if (pass.contains(RegExp(r'[ .!@#$&*~^%]'))) {
      _spatialCheck = true;
    }
    if (pass.contains(RegExp(r'[\d+]'))) {
      _numberCheck = true;
    }
    if (isUpdate) {
      update();
    }
  }

  Future<bool> saveIsStoreRegistrationSharedPref(bool status) async {
    return await authServiceInterface.saveIsStoreRegistration(status);
  }

  bool getIsStoreRegistrationSharedPref() {
    return authServiceInterface.getIsStoreRegistration();
  }

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  int _businessIndex = 0;
  int get businessIndex => _businessIndex;

  int _activeSubscriptionIndex = 0;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  PackageModel? _packageModel;
  PackageModel? get packageModel => _packageModel;

  void changeFirstTimeStatus() {
    _isFirstTime = !_isFirstTime;
  }

  void resetBusiness() {
    final configModel = Get.find<SplashController>().configModel;
    _businessIndex =
        (configModel?.commissionBusinessModel == 0)
            ? 1
            : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    _isFirstTime = true;
    _paymentIndex =
        (configModel?.subscriptionFreeTrialStatus ?? false)
            ? 0
            : 1;
  }

  Future<void> getPackageList({bool isUpdate = true, int? moduleId}) async {
    _packageModel =
        await authServiceInterface.getPackageList(moduleId: moduleId);
    if (isUpdate) {
      update();
    }
  }

  void setBusiness(int business) {
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status) {
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index) {
    _activeSubscriptionIndex = index;
    update();
  }

  String getModuleType() {
    return authServiceInterface.getModuleType();
  }

  void setModuleType(String type) {
    authServiceInterface.setModuleType(type);
  }
}