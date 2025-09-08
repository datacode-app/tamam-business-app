// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class DeliverymanRepositoryInterface implements RepositoryInterface {
  Future<List<DeliveryManModel>?> getDeliveryManList();
  Future<dynamic> addDeliveryMan(DeliveryManModel deliveryMan, String pass,
      XFile? image, List<XFile> identities, String token, bool isAdd);
  Future<dynamic> deleteDeliveryMan(int? deliveryManID);
  Future<dynamic> updateDeliveryManStatus(int? deliveryManID, int status);
  Future<List<ReviewModel>?> getDeliveryManReviews(int? deliveryManID);
  Future<List<DeliveryManScheduleModel>?> getDriverSchedule(int driverId);
  Future<dynamic> setDriverSchedule(
      int driverId, List<DeliveryManScheduleModel> schedules);
  Future<XFile?> pickImageFromGallery();
}
