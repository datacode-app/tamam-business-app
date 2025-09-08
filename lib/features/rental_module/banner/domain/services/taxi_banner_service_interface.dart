// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/rental_module/banner/domain/models/taxi_banner_list_model.dart';

abstract class TaxiBannerServiceInterface {
  Future<bool> addBanner({required Banners? taxiBanner, required XFile image});
  Future<bool> updateBanner({required Banners? taxiBanner, XFile? image});
  Future<BannerListModel?> getBannerList({required String offset});
  Future<bool> deleteBanner(int? bannerID);
  Future<Banners?> getBannerDetails(int id);
}
