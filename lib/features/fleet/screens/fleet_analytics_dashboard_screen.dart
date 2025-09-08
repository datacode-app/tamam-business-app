// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/features/fleet/controllers/fleet_analytics_controller.dart';
import 'package:tamam_business/util/dimensions.dart';

class FleetAnalyticsDashboardScreen extends StatefulWidget {
  const FleetAnalyticsDashboardScreen({super.key});

  @override
  State<FleetAnalyticsDashboardScreen> createState() =>
      _FleetAnalyticsDashboardScreenState();
}

class _FleetAnalyticsDashboardScreenState
    extends State<FleetAnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<FleetAnalyticsController>().getFleetAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'fleet_analytics'.tr),
      body:
          GetBuilder<FleetAnalyticsController>(builder: (analyticsController) {
        return analyticsController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : analyticsController.fleetAnalyticsModel != null
                ? SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      children: [
                        AnalyticsCard(
                          title: 'active_drivers'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.activeDrivers
                              .toString(),
                        ),
                        AnalyticsCard(
                          title: 'orders_today'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.totalOrdersToday
                              .toString(),
                        ),
                        AnalyticsCard(
                          title: 'orders_this_week'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.totalOrdersThisWeek
                              .toString(),
                        ),
                        AnalyticsCard(
                          title: 'orders_this_month'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.totalOrdersThisMonth
                              .toString(),
                        ),
                        AnalyticsCard(
                          title: 'total_distance_traveled'.tr,
                          value:
                              '${analyticsController.fleetAnalyticsModel!.totalDistanceTraveled?.toStringAsFixed(2)} km',
                        ),
                        AnalyticsCard(
                          title: 'avg_delivery_time'.tr,
                          value:
                              '${analyticsController.fleetAnalyticsModel!.avgDeliveryTime?.toStringAsFixed(2)} min',
                        ),
                        AnalyticsCard(
                          title: 'fuel_consumption'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.fuelConsumption!,
                        ),
                        AnalyticsCard(
                          title: 'on_time_delivery_rate'.tr,
                          value: analyticsController
                              .fleetAnalyticsModel!.onTimeDeliveryRate!,
                        ),
                      ],
                    ),
                  )
                : Center(child: Text('no_data_found'.tr));
      }),
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;

  const AnalyticsCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
