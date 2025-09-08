// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/features/banner/domain/models/store_banner_list_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class BannerRepositoryInterface extends RepositoryInterface {
  Future<bool> addBanner({required StoreBannerListModel? banner, required XFile image});
  Future<bool> updateBanner({required StoreBannerListModel? banner, XFile? image});
}
