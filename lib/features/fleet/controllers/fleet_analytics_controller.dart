// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/fleet/domain/models/fleet_analytics_model.dart';
import 'package:tamam_business/features/fleet/domain/services/fleet_service_interface.dart';

class FleetAnalyticsController extends GetxController implements GetxService {
  final FleetServiceInterface fleetServiceInterface;
  FleetAnalyticsController({required this.fleetServiceInterface});

  FleetAnalyticsModel? _fleetAnalyticsModel;
  FleetAnalyticsModel? get fleetAnalyticsModel => _fleetAnalyticsModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getFleetAnalytics() async {
    _isLoading = true;
    update();
    FleetAnalyticsModel? fleetAnalyticsModel =
        await fleetServiceInterface.getFleetAnalytics();
    if (fleetAnalyticsModel != null) {
      _fleetAnalyticsModel = fleetAnalyticsModel;
    }
    _isLoading = false;
    update();
  }
}
