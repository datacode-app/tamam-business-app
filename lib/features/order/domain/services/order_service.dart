// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:tamam_business/features/order/domain/models/order_details_model.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/features/order/domain/models/update_status_body_model.dart';
import 'package:tamam_business/features/order/domain/repositories/order_repository_interface.dart';
import 'package:tamam_business/features/order/domain/services/order_service_interface.dart';

class OrderService implements OrderServiceInterface {
  final OrderRepositoryInterface orderRepositoryInterface;
  OrderService({required this.orderRepositoryInterface});

  @override
  Future<List<OrderModel>?> getCurrentOrders() async {
    return await orderRepositoryInterface.getList();
  }

  @override
  Future<PaginatedOrderModel?> getPaginatedOrderList(int offset, String status) async {
    return await orderRepositoryInterface.getPaginatedOrderList(offset, status);
  }

  @override
  Future<ResponseModel> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment) async {
    return await orderRepositoryInterface.updateOrderStatus(updateStatusBody, proofAttachment);
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int orderID) async {
    return await orderRepositoryInterface.getOrderDetails(orderID);
  }

  @override
  Future<OrderModel?> getOrderWithId(int orderId) async {
    return await orderRepositoryInterface.get(orderId);
  }

  @override
  Future<ResponseModel> updateOrderAmount(Map<String, String> body) async {
    return await orderRepositoryInterface.update(body);
  }

  @override
  Future<OrderCancellationBodyModel?> getCancelReasons() async {
    return await orderRepositoryInterface.getCancelReasons();
  }

  @override
  Future<bool> sendDeliveredNotification(int? orderID) async {
    return await orderRepositoryInterface.sendDeliveredNotification(orderID);
  }

  @override
  List<MultipartBody> processMultipartData(List<XFile> pickedPrescriptions) {
    List<MultipartBody> multiParts = [];
    for(XFile file in pickedPrescriptions) {
      multiParts.add(MultipartBody('order_proof[]', file));
    }
    return multiParts;
  }

  @override
  Future<void> setBluetoothAddress(String? address) async {
    await orderRepositoryInterface.setBluetoothAddress(address);
  }

  @override
  String? getBluetoothAddress() => orderRepositoryInterface.getBluetoothAddress();

  // Driver Assignment Methods - TEMPORARILY DISABLED
  // TODO: Re-enable after database migrations and proper testing
  // @override
  // Future<Map<String, dynamic>?> getAvailableDrivers(int orderId) async {
  //   return await orderRepositoryInterface.getAvailableDrivers(orderId);
  // }

  // @override
  // Future<ResponseModel> assignDriverToOrder(int orderId, int driverId, String assignmentType) async {
  //   return await orderRepositoryInterface.assignDriverToOrder(orderId, driverId, assignmentType);
  // }
}
