// Project imports:
import 'package:tamam_business/features/fleet/domain/models/fleet_analytics_model.dart';
import 'package:tamam_business/features/fleet/domain/models/fleet_dashboard_model.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class FleetRepositoryInterface extends RepositoryInterface {
  Future<FleetDashboardModel?> getFleetDashboard();
  Future<FleetAnalyticsModel?> getFleetAnalytics();
}
