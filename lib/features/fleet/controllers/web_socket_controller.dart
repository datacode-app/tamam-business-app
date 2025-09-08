// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Project imports:
import 'package:tamam_business/features/fleet/controllers/fleet_dashboard_controller.dart';

class WebSocketController extends GetxController {
  WebSocketChannel? _channel;
  static const String _webSocketUrl = String.fromEnvironment('WEBSOCKET_URL',
      defaultValue: 'ws://localhost:6001');

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'location_update') {
          final fleetController = Get.find<FleetDashboardController>();
          fleetController.updateDriverLocation(
            data['driver_id'],
            data['lat'],
            data['lng'],
          );
        }
      });
    } catch (e) {
      // print('Error connecting to WebSocket: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

// TEST: Minimal import for web_socket_channel
// Remove after test
// void testWebSocketChannel() {
//   final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:6001'));
// }
