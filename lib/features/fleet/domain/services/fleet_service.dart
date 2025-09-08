// Project imports:
import 'package:tamam_business/features/fleet/domain/models/fleet_analytics_model.dart';
import 'package:tamam_business/features/fleet/domain/models/fleet_dashboard_model.dart';
import 'package:tamam_business/features/fleet/domain/repositories/fleet_repository_interface.dart';
import 'package:tamam_business/features/fleet/domain/services/fleet_service_interface.dart';

class FleetService implements FleetServiceInterface {
  final FleetRepositoryInterface fleetRepositoryInterface;
  FleetService({required this.fleetRepositoryInterface});

  @override
  Future<FleetDashboardModel?> getFleetDashboard() async {
    return await fleetRepositoryInterface.getFleetDashboard();
  }

  @override
  Future<FleetAnalyticsModel?> getFleetAnalytics() async {
    return await fleetRepositoryInterface.getFleetAnalytics();
  }
}
