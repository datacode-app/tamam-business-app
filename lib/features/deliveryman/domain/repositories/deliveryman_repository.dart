// Package imports:
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/features/deliveryman/domain/repositories/deliveryman_repository_interface.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';
import 'package:tamam_business/util/app_constants.dart';

class DeliveryManRepository implements DeliverymanRepositoryInterface {
  final ApiClient apiClient;
  DeliveryManRepository({required this.apiClient});

  @override
  Future<List<DeliveryManModel>?> getDeliveryManList() async {
    List<DeliveryManModel>? deliveryManList;
    Response response = await apiClient.getData(
      AppConstants.deliveryManListUri,
    );
    if (response.statusCode == 200) {
      deliveryManList = [];
      response.body.forEach(
        (deliveryMan) =>
            deliveryManList!.add(DeliveryManModel.fromJson(deliveryMan)),
      );
    }
    return deliveryManList;
  }

  @override
  Future<Response> addDeliveryMan(
    DeliveryManModel deliveryMan,
    String pass,
    XFile? image,
    List<XFile> identities,
    String token,
    bool isAdd,
  ) async {
    Map<String, String> fields = {
      'f_name': deliveryMan.fName ?? '',
      'l_name': deliveryMan.lName ?? '',
      'email': deliveryMan.email ?? '',
      'phone': deliveryMan.phone ?? '',
      'identity_type': deliveryMan.identityType ?? '',
      'identity_number': deliveryMan.identityNumber ?? '',
    };

    // Add password only for new delivery men
    if (isAdd) {
      fields['password'] = pass;
    } else {
      // For updates, add the delivery man ID
      // The backend should detect this is an update based on ID presence
      fields['id'] = deliveryMan.id.toString();
      // Don't send password for updates to avoid validation conflicts
    }

    List<MultipartBody> multipartBodies = [];

    // Only add image if it's provided
    if (image != null) {
      multipartBodies.add(MultipartBody('image', image));
    }

    // Add identity images
    for (var identity in identities) {
      multipartBodies.add(MultipartBody('identity_image[]', identity));
    }

    // Use different endpoints for add vs update
    String endpoint = isAdd 
        ? AppConstants.addDeliveryManUri 
        : '${AppConstants.updateDeliveryManUri}/${deliveryMan.id}';
    
    return await apiClient.postMultipartData(
      endpoint,
      fields,
      multipartBodies,
    );
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> deleteDeliveryMan(int? deliveryManID) async {
    return await apiClient.postData(AppConstants.deleteDeliveryManUri, {
      'id': deliveryManID,
    });
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<ReviewModel>?> getDeliveryManReviews(int? deliveryManID) async {
    List<ReviewModel>? dmReviewList;
    Response response = await apiClient.getData(
      '${AppConstants.dmReviewUri}?delivery_man_id=$deliveryManID',
    );
    if (response.statusCode == 200) {
      dmReviewList = [];
      response.body['reviews'].forEach(
        (review) => dmReviewList!.add(ReviewModel.fromJson(review)),
      );
    }
    return dmReviewList;
  }

  @override
  Future<List<DeliveryManScheduleModel>?> getDriverSchedule(
    int driverId,
  ) async {
    List<DeliveryManScheduleModel>? schedules;
    Response response = await apiClient.getData(
      '${AppConstants.deliveryManScheduleUri}?driver_id=$driverId',
    );
    if (response.statusCode == 200) {
      schedules = [];
      response.body.forEach(
        (schedule) =>
            schedules!.add(DeliveryManScheduleModel.fromJson(schedule)),
      );
    }
    return schedules;
  }

  @override
  Future getList({int? offset}) async {
    return await getDeliveryManList();
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    return await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  @override
  Future<Response> setDriverSchedule(
    int driverId,
    List<DeliveryManScheduleModel> schedules,
  ) async {
    return await apiClient.postData(AppConstants.deliveryManScheduleUri, {
      'driver_id': driverId,
      'schedule': schedules.map((e) => e.toJson()).toList(),
    });
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<Response> updateDeliveryManStatus(
    int? deliveryManID,
    int status,
  ) async {
    return await apiClient.postData(AppConstants.updateDmStatusUri, {
      'id': deliveryManID,
      'status': status,
    });
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }
}
