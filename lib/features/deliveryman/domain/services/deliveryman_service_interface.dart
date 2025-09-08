// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';

abstract class DeliverymanServiceInterface {
  Future<List<DeliveryManModel>?> getDeliveryManList();
  Future<bool> addDeliveryMan(
      DeliveryManModel deliveryMan,
      String pass,
      XFile? pickedImage,
      List<XFile> pickedIdentities,
      String token,
      bool isAdd);
  Future<bool> deleteDeliveryMan(int? deliveryManID);
  Future<bool> updateDeliveryManStatus(int? deliveryManID, int status);
  Future<List<ReviewModel>?> getDeliveryManReviews(int? deliveryManID);
  int identityTypeIndex(List<String> identityTypeList, String? identityType);
  Future<XFile?> pickImageFromGallery();
  Future<List<DeliveryManScheduleModel>?> getDriverSchedule(int driverId);
  Future<bool> setDriverSchedule(
      int driverId, List<DeliveryManScheduleModel> schedules);
}
