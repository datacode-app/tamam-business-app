// Project imports:
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';

class FleetDashboardModel {
  List<DeliveryManModel>? drivers;
  int? onlineDrivers;
  int? ordersInProgress;

  FleetDashboardModel({
    this.drivers,
    this.onlineDrivers,
    this.ordersInProgress,
  });

  FleetDashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['drivers'] != null) {
      drivers = <DeliveryManModel>[];
      json['drivers'].forEach((v) {
        drivers!.add(DeliveryManModel.fromJson(v));
      });
    }
    onlineDrivers = json['online_drivers'];
    ordersInProgress = json['orders_in_progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (drivers != null) {
      data['drivers'] = drivers!.map((v) => v.toJson()).toList();
    }
    data['online_drivers'] = onlineDrivers;
    data['orders_in_progress'] = ordersInProgress;
    return data;
  }
}
