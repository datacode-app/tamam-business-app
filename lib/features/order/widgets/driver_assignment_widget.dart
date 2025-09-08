// FLEET MANAGEMENT WIDGET - TEMPORARILY DISABLED FOR STABLE RELEASE
// TODO: Re-enable after completing database migrations and proper testing

/*
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/custom_loader_widget.dart';
import 'package:tamam_business/features/order/controllers/order_controller.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class DriverAssignmentWidget extends StatelessWidget {
  final OrderModel order;
  const DriverAssignmentWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      // Don't show if order already has driver or not eligible
      if (order.deliveryMan != null || 
          !['pending', 'confirmed', 'accepted'].contains(order.orderStatus)) {
        return const SizedBox();
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).primaryColor.withAlpha((0.3 * 255).round()),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    'Driver Assignment',
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            
            if (orderController.isLoadingDrivers)
              const Center(child: CustomLoaderWidget())
            else if (orderController.availableDrivers?.isNotEmpty ?? false) ...[
              Text(
                '${orderController.availableDrivers!.length} drivers available',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Expanded(
                    child: CustomButtonWidget(
                      buttonText: 'Auto Assign',
                      height: 35,
                      fontSize: Dimensions.fontSizeSmall,
                      onPressed: () => orderController.autoAssignBestDriver(order.id!),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: CustomButtonWidget(
                      buttonText: 'Select Driver',
                      height: 35,
                      fontSize: Dimensions.fontSizeSmall,
                      backgroundColor: Theme.of(context).cardColor,
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        // Navigate to driver selection screen
                        // Get.toNamed(RouteHelper.getSelectDeliveryManRoute(order.id!));
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No drivers available at the moment',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomButtonWidget(
                buttonText: 'Refresh',
                height: 35,
                fontSize: Dimensions.fontSizeSmall,
                onPressed: () => orderController.getAvailableDrivers(order.id!),
              ),
            ],
          ],
        ),
      );
    });
  }
}
*/