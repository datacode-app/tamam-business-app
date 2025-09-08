// Project imports:
import 'package:tamam_business/features/fleet/domain/models/fleet_analytics_model.dart';
import 'package:tamam_business/features/fleet/domain/models/fleet_dashboard_model.dart';

abstract class FleetServiceInterface {
  Future<FleetDashboardModel?> getFleetDashboard();
  Future<FleetAnalyticsModel?> getFleetAnalytics();
}
