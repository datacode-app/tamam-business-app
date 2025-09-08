// FLEET MANAGEMENT FEATURE - TEMPORARILY DISABLED FOR STABLE RELEASE
// TODO: Re-enable after completing database migrations and proper testing

/*
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/custom_image_widget.dart';
import 'package:tamam_business/features/order/controllers/order_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class SelectDeliveryManScreen extends StatefulWidget {
  final int orderId;
  const SelectDeliveryManScreen({super.key, required this.orderId});

  @override
  State<SelectDeliveryManScreen> createState() => _SelectDeliveryManScreenState();
}

class _SelectDeliveryManScreenState extends State<SelectDeliveryManScreen> {
  // Feature flag for driver assignment - can be controlled from backend
  static const bool _isDriverAssignmentEnabled = false; // DISABLED
  
  @override
  void initState() {
    super.initState();
    if (_isDriverAssignmentEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<OrderController>().getAvailableDrivers(widget.orderId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(title: 'select_delivery_man'.tr),
      body: !_isDriverAssignmentEnabled
          ? _buildFeatureNotAvailableState()
          : GetBuilder<OrderController>(builder: (orderController) {
              return orderController.isLoadingDrivers
                  ? const Center(child: CircularProgressIndicator())
                  : orderController.availableDrivers != null &&
                          orderController.availableDrivers!.isNotEmpty
                      ? SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
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
                              Row(children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Text(
                                    'select_delivery_man_for_order'.tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Text(
                                '${'order_id'.tr}: #${widget.orderId}',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Available delivery men count
                        Text(
                          '${'available_delivery_men'.tr} (${orderController.availableDrivers!.length})',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Auto-assign button
                        CustomButtonWidget(
                          buttonText: 'auto_assign_best_driver'.tr,
                          onPressed: () => _showAutoAssignDialog(orderController),
                          height: 45,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Delivery men list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderController.availableDrivers!.length,
                          itemBuilder: (context, index) {
                            final driver = orderController.availableDrivers![index];
                            return _buildDeliveryManCard(driver, orderController);
                          },
                        ),
                      ],
                    ),
                  )
                : _buildEmptyState(orderController);
            }),
    );
  }

  Widget _buildDeliveryManCard(Map<String, dynamic> driver, OrderController orderController) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withAlpha((0.3 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((0.1 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImageWidget(
                  image: (driver['image'] != null && driver['image'].isNotEmpty) ? driver['image'] : '',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${driver['f_name'] ?? ''} ${driver['l_name'] ?? ''}',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                          child: Text(
                            driver['phone'] ?? 'no_phone'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Colors.green.withAlpha((0.3 * 255).round())),
                ),
                child: Text(
                  'available'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          // Driver Stats
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'rating'.tr,
                '${driver['avg_rating'] ?? 0.0}',
                Icons.star,
                Colors.orange,
              ),
              _buildStatItem(
                'orders'.tr,
                '${driver['order_count'] ?? 0}',
                Icons.shopping_bag,
                Theme.of(context).primaryColor,
              ),
              _buildStatItem(
                'distance'.tr,
                '${driver['distance'] ?? 0.0} km',
                Icons.location_on,
                Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
          
          // Assign Button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () => _showAssignDialog(driver, orderController),
              tooltip: 'assign_to_this_delivery_man'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          value,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(OrderController orderController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Images.emptyBox,
              height: 150,
              width: 150,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'no_delivery_men_available'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'no_available_delivery_men_message'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButtonWidget(
              buttonText: 'try_auto_assignment'.tr,
              onPressed: () => _showAutoAssignDialog(orderController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureNotAvailableState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 100,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'Feature Coming Soon',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Driver assignment feature is currently being deployed. Please check back later.',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButtonWidget(
              buttonText: 'go_back'.tr,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(Map<String, dynamic> driver, OrderController orderController) {
    Get.dialog(
      ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'confirm_assignment'.tr,
        description: '${'assign_order_to'.tr} ${driver['f_name']} ${driver['l_name']}?',
        onYesPressed: () {
          orderController.assignDriverToOrder(widget.orderId, driver['id']).then((success) {
            Get.back(); // Close dialog
            if (success) {
              Get.back(); // Go back to previous screen
            }
          });
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showAutoAssignDialog(OrderController orderController) {
    Get.dialog(
      ConfirmationDialogWidget(
        icon: Images.warning,
        title: 'auto_assign_confirmation'.tr,
        description: 'auto_assign_confirmation_message'.tr,
        onYesPressed: () {
          orderController.autoAssignBestDriver(widget.orderId).then((success) {
            Get.back(); // Close dialog
            if (success) {
              Get.back(); // Go back to previous screen
            }
          });
        },
      ),
      barrierDismissible: false,
    );
  }
}
*/