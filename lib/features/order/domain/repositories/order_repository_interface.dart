// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/order/domain/models/update_status_body_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class OrderRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getPaginatedOrderList(int offset, String status);
  Future<dynamic> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment);
  Future<dynamic> getOrderDetails(int orderID);
  Future<dynamic> getCancelReasons();
  Future<dynamic> sendDeliveredNotification(int? orderID);
  Future<void> setBluetoothAddress(String? address);
  String? getBluetoothAddress();
  
  // Driver Assignment Methods - TEMPORARILY DISABLED
  // TODO: Re-enable after database migrations and proper testing
  // Future<dynamic> getAvailableDrivers(int orderId);
  // Future<dynamic> assignDriverToOrder(int orderId, int driverId, String assignmentType);
}
