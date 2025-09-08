// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/fleet/domain/models/fleet_analytics_model.dart';
import 'package:tamam_business/features/fleet/domain/models/fleet_dashboard_model.dart';
import 'package:tamam_business/features/fleet/domain/repositories/fleet_repository_interface.dart';
import 'package:tamam_business/util/app_constants.dart';

class FleetRepository implements FleetRepositoryInterface {
  final ApiClient apiClient;
  FleetRepository({required this.apiClient});

  @override
  Future<FleetDashboardModel?> getFleetDashboard() async {
    FleetDashboardModel? fleetDashboardModel;
    Response response = await apiClient.getData(AppConstants.fleetDashboardUri);
    if (response.statusCode == 200) {
      fleetDashboardModel = FleetDashboardModel.fromJson(response.body);
    }
    return fleetDashboardModel;
  }

  @override
  Future<FleetAnalyticsModel?> getFleetAnalytics() async {
    FleetAnalyticsModel? fleetAnalyticsModel;
    Response response =
        await apiClient.getData(AppConstants.getFleetAnalyticsUri);
    if (response.statusCode == 200) {
      fleetAnalyticsModel = FleetAnalyticsModel.fromJson(response.body);
    }
    return fleetAnalyticsModel;
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
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
