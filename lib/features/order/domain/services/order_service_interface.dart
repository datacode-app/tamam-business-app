// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:tamam_business/features/order/domain/models/order_details_model.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/features/order/domain/models/update_status_body_model.dart';

abstract class OrderServiceInterface {
  Future<List<OrderModel>?> getCurrentOrders();
  Future<PaginatedOrderModel?> getPaginatedOrderList(int offset, String status);
  Future<ResponseModel> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment);
  Future<List<OrderDetailsModel>?> getOrderDetails(int orderID);
  Future<OrderModel?> getOrderWithId(int orderId);
  Future<ResponseModel> updateOrderAmount(Map<String, String> body);
  Future<OrderCancellationBodyModel?> getCancelReasons();
  Future<bool> sendDeliveredNotification(int? orderID);
  List<MultipartBody> processMultipartData(List<XFile> pickedPrescriptions);
  Future<void> setBluetoothAddress(String? address);
  String? getBluetoothAddress();
  
  // Driver Assignment Methods - TEMPORARILY DISABLED
  // TODO: Re-enable after database migrations and proper testing
  // Future<Map<String, dynamic>?> getAvailableDrivers(int orderId);
  // Future<ResponseModel> assignDriverToOrder(int orderId, int driverId, String assignmentType);
}
