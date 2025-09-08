// Project imports:
import 'package:tamam_business/features/profile/domain/models/profile_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class ForgotPasswordRepositoryInterface implements RepositoryInterface {
  Future<dynamic> changePassword(ProfileModel userInfoModel, String password);
  Future<dynamic> forgetPassword(String? email);
  Future<dynamic> verifyToken(String? email, String token);
  Future<dynamic> resetPassword(String? resetToken, String? email, String password, String confirmPassword);
}
