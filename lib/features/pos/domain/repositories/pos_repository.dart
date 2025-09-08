// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/pos/domain/repositories/pos_repository_interface.dart';
import 'package:tamam_business/util/app_constants.dart';

class PosRepository implements PosRepositoryInterface {
  final ApiClient apiClient;
  PosRepository({required this.apiClient});

  @override
  Future<Response> searchItemList(String searchText) async {
    return await apiClient.postData(AppConstants.searchItemListUri, {'name': searchText});
  }

  @override
  Future<Response> searchCustomerList(String searchText) async {
    return await apiClient.getData('${AppConstants.searchCustomersUri}?search=$searchText');
  }

  @override
  Future<Response> placeOrder(String searchText) async {
    return await apiClient.postData(AppConstants.placeOrderUri, {});
  }

  @override
  Future<Response> getPosOrders() async {
    return await apiClient.getData(AppConstants.posOrderUri);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}
