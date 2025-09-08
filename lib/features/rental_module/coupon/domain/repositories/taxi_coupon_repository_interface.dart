// Project imports:
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/rental_module/coupon/domain/models/taxi_coupon_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class TaxiCouponRepositoryInterface implements RepositoryInterface {
  Future<TaxiCouponModel?> getCouponList({required String offset});
  Future<dynamic> addCoupon(Map<String, String?> data);
  Future<bool> changeStatus(int? couponId);
  Future<ResponseModel> updateCoupon(Map<String, dynamic> body, int? id);
}
