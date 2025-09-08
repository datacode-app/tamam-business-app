// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/features/deliveryman/domain/services/deliveryman_service_interface.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';

class DeliveryManController extends GetxController implements GetxService {
  final DeliverymanServiceInterface deliverymanServiceInterface;
  DeliveryManController({required this.deliverymanServiceInterface});

  List<DeliveryManModel>? _deliveryManList;
  List<DeliveryManModel>? get deliveryManList => _deliveryManList;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  int _identityTypeIndex = 0;
  int get identityTypeIndex => _identityTypeIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ReviewModel>? _dmReviewList;
  List<ReviewModel>? get dmReviewList => _dmReviewList;

  bool _isSuspended = false;
  bool get isSuspended => _isSuspended;

  List<DeliveryManScheduleModel>? _driverSchedules;
  List<DeliveryManScheduleModel>? get driverSchedules => _driverSchedules;

  Future<void> getDeliveryManList() async {
    List<DeliveryManModel>? deliveryManList =
        await deliverymanServiceInterface.getDeliveryManList();
    if (deliveryManList != null) {
      _deliveryManList = [];
      _deliveryManList!.addAll(deliveryManList);
    }
    _isLoading = false;
    update();
  }

  Future<void> addDeliveryMan(DeliveryManModel deliveryMan, String pass,
      String token, bool isAdd) async {
    _isLoading = true;
    update();
    bool isSuccess = await deliverymanServiceInterface.addDeliveryMan(
        deliveryMan, pass, _pickedImage, _pickedIdentities, token, isAdd);
    if (isSuccess) {
      Get.back();
      showCustomSnackBar(
          isAdd
              ? 'delivery_man_added_successfully'.tr
              : 'delivery_man_updated_successfully'.tr,
          isError: false);
      getDeliveryManList();
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteDeliveryMan(int? deliveryManID) async {
    _isLoading = true;
    update();
    bool isSuccess =
        await deliverymanServiceInterface.deleteDeliveryMan(deliveryManID);
    if (isSuccess) {
      Get.back();
      showCustomSnackBar('delivery_man_deleted_successfully'.tr,
          isError: false);
      getDeliveryManList();
    }
    _isLoading = false;
    update();
  }

  Future<void> getDriverSchedule(int driverId) async {
    _driverSchedules = null;
    update();
    List<DeliveryManScheduleModel>? schedules =
        await deliverymanServiceInterface.getDriverSchedule(driverId);
    if (schedules != null) {
      _driverSchedules = [];
      _driverSchedules!.addAll(schedules);
    }
    update();
  }

  Future<void> setDriverSchedule(
      int driverId, List<DeliveryManScheduleModel> schedules) async {
    _isLoading = true;
    update();
    bool isSuccess = await deliverymanServiceInterface.setDriverSchedule(
        driverId, schedules);
    if (isSuccess) {
      Get.back();
      showCustomSnackBar('schedule_updated_successfully'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  void updateDriverSchedule(int day, String start, String end) {
    int index = _driverSchedules!.indexWhere((element) => element.day == day);
    if (index != -1) {
      _driverSchedules![index].startTime = start;
      _driverSchedules![index].endTime = end;
    } else {
      _driverSchedules!.add(
          DeliveryManScheduleModel(day: day, startTime: start, endTime: end));
    }
    update();
  }

  void setSuspended(bool isSuspended) {
    _isSuspended = isSuspended;
  }

  void toggleSuspension(int? deliveryManID) async {
    _isLoading = true;
    update();
    bool isSuccess = await deliverymanServiceInterface.updateDeliveryManStatus(
        deliveryManID, _isSuspended ? 1 : 0);
    if (isSuccess) {
      Get.back();
      getDeliveryManList();
      showCustomSnackBar(
          _isSuspended
              ? 'delivery_man_unsuspended_successfully'.tr
              : 'delivery_man_suspended_successfully'.tr,
          isError: false);
      _isSuspended = !_isSuspended;
    }
    _isLoading = false;
    update();
  }

  Future<void> getDeliveryManReviewList(int? deliveryManID) async {
    _dmReviewList = null;
    List<ReviewModel>? dmReviewList =
        await deliverymanServiceInterface.getDeliveryManReviews(deliveryManID);
    if (dmReviewList != null) {
      _dmReviewList = [];
      _dmReviewList!.addAll(dmReviewList);
    }
    update();
  }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = deliverymanServiceInterface.identityTypeIndex(
        _identityTypeList, identityType);
    _identityTypeIndex = index0;
    if (notify) {
      update();
    }
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage = await deliverymanServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentitiesImage =
            await deliverymanServiceInterface.pickImageFromGallery();
        if (pickedIdentitiesImage != null) {
          _pickedIdentities.add(pickedIdentitiesImage);
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }
}
