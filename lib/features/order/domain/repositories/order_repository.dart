// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/common/models/response_model.dart';
import 'package:tamam_business/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:tamam_business/features/order/domain/models/order_details_model.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/features/order/domain/models/update_status_body_model.dart';
import 'package:tamam_business/features/order/domain/repositories/order_repository_interface.dart';
import 'package:tamam_business/util/app_constants.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<List<OrderModel>?> getList() async {
    List<OrderModel>? runningOrderList;
    Response response = await apiClient.getData(AppConstants.currentOrdersUri);
    if (response.statusCode == 200) {
      runningOrderList = [];
      response.body.forEach((order) {
        OrderModel orderModel = OrderModel.fromJson(order);
        runningOrderList!.add(orderModel);
      });
    }
    return runningOrderList;
  }

  @override
  Future<PaginatedOrderModel?> getPaginatedOrderList(int offset, String status) async {
    PaginatedOrderModel? historyOrderModel;
    Response response = await apiClient.getData('${AppConstants.completedOrdersUri}?status=$status&offset=$offset&limit=10');
    if (response.statusCode == 200) {
      historyOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return historyOrderModel;
  }

  @override
  Future<ResponseModel> updateOrderStatus(UpdateStatusBodyModel updateStatusBody, List<MultipartBody> proofAttachment) async {
    ResponseModel responseModel;
    Response response = await apiClient.postMultipartData(AppConstants.updatedOrderStatusUri, updateStatusBody.toJson(), proofAttachment, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(int orderID) async {
    List<OrderDetailsModel>? orderDetailsModel;
    Response response = await apiClient.getData('${AppConstants.orderDetailsUri}$orderID');
    if(response.statusCode == 200) {
      orderDetailsModel = [];
      response.body.forEach((orderDetails) => orderDetailsModel!.add(OrderDetailsModel.fromJson(orderDetails)));
    }
    return orderDetailsModel;
  }

  @override
  Future<OrderModel?> get(int? id) async {
    OrderModel? orderModel;
    Response response = await apiClient.getData('${AppConstants.currentOrderDetailsUri}$id');
    if (response.statusCode == 200) {
      orderModel = OrderModel.fromJson(response.body);
    }
    return orderModel;
  }

  @override
  Future<ResponseModel> update(Map<String, dynamic> body) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.updateOrderUri, body, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<OrderCancellationBodyModel?> getCancelReasons() async {
    OrderCancellationBodyModel? orderCancellationBody;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=store');
    if (response.statusCode == 200) {
      orderCancellationBody = OrderCancellationBodyModel.fromJson(response.body);
    }
    return orderCancellationBody;
  }

  @override
  Future<bool> sendDeliveredNotification(int? orderID) async {
    Response response = await apiClient.postData(AppConstants.deliveredOrderNotificationUri, {"_method": "put", 'token': _getUserToken(), 'order_id': orderID});
    return (response.statusCode == 200);
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
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
  Future<void> setBluetoothAddress(String? address) async {
    await sharedPreferences.setString(AppConstants.bluetoothMacAddress, address ?? '');
  }
  @override
  String? getBluetoothAddress() => sharedPreferences.getString(AppConstants.bluetoothMacAddress);

  // Driver Assignment Methods - TEMPORARILY DISABLED
  // TODO: Re-enable after database migrations and proper testing
  // @override
  // Future<Map<String, dynamic>?> getAvailableDrivers(int orderId) async {
  //   try {
  //     Response response = await apiClient.getData('${AppConstants.getAvailableDriversUri}/$orderId/available-drivers');
  //     if (response.statusCode == 200) {
  //       return response.body;
  //     } else if (response.statusCode == 404) {
  //       // New endpoint not available yet - graceful fallback
  //       debugPrint('Driver assignment endpoint not found (404) - feature not deployed yet');
  //       return null;
  //     } else {
  //       debugPrint('Error fetching available drivers: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     // Network error or other exception - graceful fallback
  //     debugPrint('Exception fetching available drivers: $e');
  //     return null;
  //   }
  // }

  // @override
  // Future<ResponseModel> assignDriverToOrder(int orderId, int driverId, String assignmentType) async {
  //   try {
  //     Response response = await apiClient.postData(
  //       '${AppConstants.assignDriverToOrderUri}/$orderId/assign-driver',
  //       {
  //         'delivery_man_id': driverId,
  //         'assignment_type': assignmentType,
  //       },
  //     );
  //     
  //     if (response.statusCode == 200) {
  //       return ResponseModel(true, response.body['message'] ?? 'Driver assigned successfully');
  //     } else if (response.statusCode == 404) {
  //       // New endpoint not available yet - graceful fallback
  //       debugPrint('Driver assignment endpoint not found (404) - feature not deployed yet');
  //       return ResponseModel(false, 'Driver assignment feature not available yet');
  //     } else {
  //       String errorMessage = response.body['message'] ?? 'Failed to assign driver';
  //       debugPrint('Error assigning driver: ${response.statusCode} - $errorMessage');
  //       return ResponseModel(false, errorMessage);
  //     }
  //   } catch (e) {
  //     // Network error or other exception - graceful fallback
  //     debugPrint('Exception assigning driver: $e');
  //     return ResponseModel(false, 'Network error: Driver assignment feature not available');
  //   }
  // }

}
