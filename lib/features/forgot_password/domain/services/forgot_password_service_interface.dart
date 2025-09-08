// Project imports:
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/profile/domain/models/profile_model.dart';

abstract class ForgotPasswordServiceInterface {
  Future<bool> changePassword(ProfileModel userInfoModel, String password);
  Future<ResponseModel> forgetPassword(String? email);
  Future<ResponseModel> verifyToken(String? email, String token);
  Future<ResponseModel> resetPassword(String? resetToken, String? email, String password, String confirmPassword);
}
