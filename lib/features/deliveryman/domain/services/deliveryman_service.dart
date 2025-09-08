// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/features/deliveryman/domain/repositories/deliveryman_repository_interface.dart';
import 'package:tamam_business/features/deliveryman/domain/services/deliveryman_service_interface.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';

class DeliverymanService implements DeliverymanServiceInterface {
  final DeliverymanRepositoryInterface deliverymanRepositoryInterface;
  DeliverymanService({required this.deliverymanRepositoryInterface});

  @override
  Future<List<DeliveryManModel>?> getDeliveryManList() async {
    return await deliverymanRepositoryInterface.getList();
  }

  @override
  Future<bool> addDeliveryMan(
    DeliveryManModel deliveryMan,
    String pass,
    XFile? image,
    List<XFile> identities,
    String token,
    bool isAdd,
  ) async {
    var response = await deliverymanRepositoryInterface.addDeliveryMan(
      deliveryMan,
      pass,
      image,
      identities,
      token,
      isAdd,
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteDeliveryMan(int? deliveryManID) async {
    return await deliverymanRepositoryInterface.delete(deliveryManID);
  }

  @override
  Future<bool> updateDeliveryManStatus(int? deliveryManID, int status) async {
    return await deliverymanRepositoryInterface.updateDeliveryManStatus(
      deliveryManID,
      status,
    );
  }

  @override
  Future<List<ReviewModel>?> getDeliveryManReviews(int? deliveryManID) async {
    return await deliverymanRepositoryInterface.get(deliveryManID);
  }

  @override
  int identityTypeIndex(List<String> identityTypeList, String? identityType) {
    int index0 = 0;
    for (int index = 0; index < identityTypeList.length; index++) {
      if (identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    return index0;
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    return await deliverymanRepositoryInterface.pickImageFromGallery();
  }

  @override
  Future<List<DeliveryManScheduleModel>?> getDriverSchedule(
    int driverId,
  ) async {
    return await deliverymanRepositoryInterface.getDriverSchedule(driverId);
  }

  @override
  Future<bool> setDriverSchedule(
    int driverId,
    List<DeliveryManScheduleModel> schedules,
  ) async {
    return await deliverymanRepositoryInterface.setDriverSchedule(
      driverId,
      schedules,
    );
  }
}
