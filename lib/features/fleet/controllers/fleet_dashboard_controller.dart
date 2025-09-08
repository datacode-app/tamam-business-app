// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/fleet/domain/models/fleet_dashboard_model.dart';
import 'package:tamam_business/features/fleet/domain/services/fleet_service_interface.dart';

class FleetDashboardController extends GetxController implements GetxService {
  final FleetServiceInterface fleetServiceInterface;
  FleetDashboardController({required this.fleetServiceInterface});

  FleetDashboardModel? _fleetDashboardModel;
  FleetDashboardModel? get fleetDashboardModel => _fleetDashboardModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getFleetDashboard() async {
    _isLoading = true;
    update();
    FleetDashboardModel? fleetDashboardModel =
        await fleetServiceInterface.getFleetDashboard();
    if (fleetDashboardModel != null) {
      _fleetDashboardModel = fleetDashboardModel;
    }
    _isLoading = false;
    update();
  }

  void updateDriverLocation(int driverId, double latitude, double longitude) {
    int index = _fleetDashboardModel!.drivers!
        .indexWhere((element) => element.id == driverId);
    if (index != -1) {
      _fleetDashboardModel!.drivers![index].lat = latitude.toString();
      _fleetDashboardModel!.drivers![index].lng = longitude.toString();
      update();
    }
  }
}
