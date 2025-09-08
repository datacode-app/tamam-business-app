// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/auth/controllers/auth_controller.dart';
import 'package:tamam_business/features/auth/domain/models/module_permission_body_model.dart';
import 'package:tamam_business/features/profile/domain/models/profile_model.dart';
import 'package:tamam_business/features/profile/domain/services/profile_service_interface.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/helper/route_helper.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  ModulePermissionBodyModel? _modulePermissionBody;
  ModulePermissionBodyModel? get modulePermission => _modulePermissionBody;

  bool _trialWidgetNotShow = false;
  bool get trialWidgetNotShow => _trialWidgetNotShow;

  bool _showLowStockWarning = true;
  bool get showLowStockWarning => _showLowStockWarning;

  void hideLowStockWarning(){
    _showLowStockWarning = !_showLowStockWarning;
  }

  Future<void> getProfile() async {
    ProfileModel? profileModel = await profileServiceInterface.getProfileInfo();
    if (profileModel != null) {
      _profileModel = profileModel;
      Get.find<SplashController>().setModule(_profileModel!.stores![0].module!.id, _profileModel!.stores![0].module!.moduleType);
      profileServiceInterface.updateHeader(_profileModel!.stores![0].module!.id);
      _allowModulePermission(_profileModel?.roles);
      
      // Debug output
      if (kDebugMode) {
        print('====> Profile loaded - Permissions set:');
        print('====> - storeSetup: ${_modulePermissionBody?.storeSetup}');
        print('====> - wallet: ${_modulePermissionBody?.wallet}');
        print('====> - order: ${_modulePermissionBody?.order}');
        print('====> - All permissions: ${_modulePermissionBody != null}');
      }
    }
    update();
  }

  Future<bool> updateUserInfo(ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    bool isSuccess = await profileServiceInterface.updateProfile(updateUserModel, _pickedFile, token);
    _isLoading = false;
    if (isSuccess) {
      await getProfile();
      Get.back();
      showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
    }
    update();
    return isSuccess;
  }

  void pickImage() async {
    XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(picked != null) {
      _pickedFile = picked;
    }
    update();
  }

  Future deleteVendor() async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.deleteVendor();
    _isLoading = false;
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }else{
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
  }

  void _allowModulePermission(List<String>? roles) {
    debugPrint('---permission--->>$roles');
    
    // Always set default permissions when roles is null or empty
    if(roles == null || roles.isEmpty) {
      debugPrint('Setting default permissions - roles is null/empty');
      _modulePermissionBody = ModulePermissionBodyModel(
        item: true, 
        order: true, 
        storeSetup: true, 
        addon: true, 
        wallet: true,
        bankInfo: true, 
        employee: true, 
        myShop: true, 
        customRole: true, 
        campaign: true, 
        reviews: true, 
        pos: true, 
        chat: true,
        myWallet: true,
      );
    } else {
      // Original permission logic
      List<String> module = roles;
      if (kDebugMode) {
        print('Setting permissions based on roles: $module');
      }
      _modulePermissionBody = ModulePermissionBodyModel(
        item: module.contains('item'),
        order: module.contains('order'),
        storeSetup: module.contains('store_setup'),
        addon: module.contains('addon'),
        wallet: module.contains('wallet'),
        bankInfo: module.contains('bank_info'),
        employee: module.contains('employee'),
        myShop: module.contains('my_shop'),
        customRole: module.contains('custom_role'),
        campaign: module.contains('campaign'),
        reviews: module.contains('reviews'),
        pos: module.contains('pos'),
        chat: module.contains('chat'),
        myWallet: module.contains('my_wallet'),
      );
    }
    
    // Force update to rebuild UI
    update();
  }

  void initData() {
    _pickedFile = null;
  }

  Future<bool> trialWidgetShow({required String route}) async {
    const Set<String> routesToHideWidget = {
      RouteHelper.mySubscription, 'show-dialog', RouteHelper.success, RouteHelper.payment, RouteHelper.signIn,
    };
    _trialWidgetNotShow = routesToHideWidget.contains(route);
    Future.delayed(const Duration(milliseconds: 500), () {
      update();
    });
    return _trialWidgetNotShow;
  }

  void initTrialWidgetNotShow(){
    _trialWidgetNotShow = false;
  }

}
