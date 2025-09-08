// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/rental_module/profile/domain/models/taxi_profile_model.dart';

abstract class TaxiProfileServiceInterface {
  Future<TaxiProfileModel?> getProfileInfo();
  Future<bool> updateProfile(TaxiProfileModel userInfoModel, XFile? data, String token);
  Future<ResponseModel> deleteVendor();
  updateHeader(int? moduleID);
}
