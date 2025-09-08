// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:tamam_business/common/widgets/analytics_card.dart';
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/fleet/controllers/fleet_dashboard_controller.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class FleetDashboardScreen extends StatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  State<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends State<FleetDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<FleetDashboardController>().getFleetDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'fleet_dashboard'.tr,
        menuWidget: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              Get.find<FleetDashboardController>().getFleetDashboard(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(null)),
        label: Text('add_driver'.tr),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GetBuilder<FleetDashboardController>(builder: (fleetController) {
        return fleetController.fleetDashboardModel != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    // Show fleet creation card when no drivers exist
                    if (fleetController.fleetDashboardModel!.drivers!.isEmpty)
                      _buildFleetCreationCard(context),

                    // Analytics Cards
                    Row(
                      children: [
                        Expanded(
                          child: AnalyticsCard(
                            title: 'online_drivers'.tr,
                            value: fleetController
                                .fleetDashboardModel!.onlineDrivers
                                .toString(),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: AnalyticsCard(
                            title: 'orders_in_progress'.tr,
                            value: fleetController
                                .fleetDashboardModel!.ordersInProgress
                                .toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Quick Actions Section
                    _buildQuickActionsSection(context),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Map Section (only show if drivers exist)
                    if (fleetController
                        .fleetDashboardModel!.drivers!.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target:
                                LatLng(23.8103, 90.4125), // Default to Dhaka
                            zoom: 12,
                          ),
                          onMapCreated: (GoogleMapController controller) {},
                          markers: _createMarkers(fleetController),
                        ),
                      ),

                    if (fleetController
                        .fleetDashboardModel!.drivers!.isNotEmpty)
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                    // View Analytics Button
                    CustomButtonWidget(
                      buttonText: 'view_analytics'.tr,
                      onPressed: () => Get.toNamed(
                          RouteHelper.getFleetAnalyticsDashboardRoute()),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Drivers List
                    if (fleetController
                        .fleetDashboardModel!.drivers!.isNotEmpty)
                      _buildDriversList(fleetController),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Set<Marker> _createMarkers(FleetDashboardController fleetController) {
    final markers = <Marker>{};
    if (fleetController.fleetDashboardModel?.drivers != null) {
      for (var driver in fleetController.fleetDashboardModel!.drivers!) {
        if (driver.lat != null && driver.lng != null) {
          markers.add(
            Marker(
              markerId: MarkerId(driver.id.toString()),
              position:
                  LatLng(double.parse(driver.lat!), double.parse(driver.lng!)),
              infoWindow: InfoWindow(title: driver.fName),
            ),
          );
        }
      }
    }
    return markers;
  }

  Widget _buildFleetCreationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'create_your_fleet'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'fleet_creation_description'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomButtonWidget(
            buttonText: 'add_first_driver'.tr,
            onPressed: () =>
                Get.toNamed(RouteHelper.getAddDeliveryManRoute(null)),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'add_driver'.tr,
                  Icons.person_add,
                  () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(null)),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'view_all_drivers'.tr,
                  Icons.group,
                  () => Get.toNamed(RouteHelper.getDeliveryManRoute()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String title,
      IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversList(FleetDashboardController fleetController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'your_drivers'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(RouteHelper.getDeliveryManRoute()),
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        ListView.builder(
          itemCount: fleetController.fleetDashboardModel!.drivers!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final driver = fleetController.fleetDashboardModel!.drivers![index];
            return Card(
              margin:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      driver.active == 1 ? Colors.green : Colors.red,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(driver.fName ?? 'Unknown'),
                subtitle: Text(driver.phone ?? 'No phone'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: driver.active == 1 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      driver.active == 1 ? 'online'.tr : 'offline'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: driver.active == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                onTap: () =>
                    Get.toNamed(RouteHelper.getDeliveryManDetailsRoute(driver)),
              ),
            );
          },
        ),
      ],
    );
  }
}
