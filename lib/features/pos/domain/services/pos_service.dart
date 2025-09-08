// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/pos/domain/repositories/pos_repository_interface.dart';
import 'package:tamam_business/features/pos/domain/services/pos_service_interface.dart';

class PosService implements PosServiceInterface {
  final PosRepositoryInterface posRepositoryInterface;
  PosService({required this.posRepositoryInterface});

  @override
  Future<Response> searchItemList(String searchText) async {
    return await posRepositoryInterface.searchItemList(searchText);
  }

  @override
  Future<Response> searchCustomerList(String searchText) async {
    return await posRepositoryInterface.searchCustomerList(searchText);
  }

  @override
  Future<Response> placeOrder(String searchText) async {
    return await posRepositoryInterface.placeOrder(searchText);
  }

  @override
  Future<Response> getPosOrders() async {
    return await posRepositoryInterface.getPosOrders();
  }

}
