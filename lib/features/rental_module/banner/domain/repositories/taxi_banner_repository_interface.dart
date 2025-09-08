// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/rental_module/banner/domain/models/taxi_banner_list_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class TaxiBannerRepositoryInterface extends RepositoryInterface {
  Future<dynamic> addBanner({required Banners? taxiBanner, required XFile image});
  Future<dynamic> updateBanner({required Banners? taxiBanner, XFile? image});
  Future<BannerListModel?> getBannerList({required String offset});
}
