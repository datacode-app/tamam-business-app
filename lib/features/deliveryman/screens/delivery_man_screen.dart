// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/analytics_card.dart';
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_image_widget.dart';
import 'package:tamam_business/features/deliveryman/controllers/deliveryman_controller.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class DeliveryManScreen extends StatelessWidget {
  const DeliveryManScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<DeliveryManController>().getDeliveryManList();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: CustomAppBarWidget(
        title: 'delivery_management'.tr,
        menuWidget: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => Get.find<DeliveryManController>().getDeliveryManList(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(null)),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add_circle_outline, color: Theme.of(context).cardColor, size: 30),
      ),

      body: GetBuilder<DeliveryManController>(builder: (dmController) {
        return dmController.deliveryManList != null ? dmController.deliveryManList!.isNotEmpty ? SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Cards
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'total_drivers'.tr,
                      value: dmController.deliveryManList!.length.toString(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'online_drivers'.tr,
                      value: dmController.deliveryManList!.where((d) => d.active == 1).length.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              
              // Drivers List Header
              Text(
                'all_drivers'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              
              // Drivers List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dmController.deliveryManList!.length,
                itemBuilder: (context, index) {
                  DeliveryManModel deliveryMan = dmController.deliveryManList![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getDeliveryManDetailsRoute(deliveryMan)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(
                          children: [
                            // Profile Image with Status Indicator
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: deliveryMan.active == 1 ? Colors.green : Colors.red, width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: CustomImageWidget(
                                      image: deliveryMan.imageFullUrl ?? '',
                                      height: 50, width: 50, fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: deliveryMan.active == 1 ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            
                            // Driver Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${deliveryMan.fName} ${deliveryMan.lName}',
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    deliveryMan.phone ?? 'no_phone'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: deliveryMan.active == 1 ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        deliveryMan.active == 1 ? 'online'.tr : 'offline'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: deliveryMan.active == 1 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => Get.toNamed(RouteHelper.getAddDeliveryManRoute(deliveryMan)),
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'edit'.tr,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.dialog(ConfirmationDialogWidget(
                                      icon: Images.warning,
                                      description: 'are_you_sure_want_to_delete_this_delivery_man'.tr,
                                      onYesPressed: () => Get.find<DeliveryManController>().deleteDeliveryMan(deliveryMan.id),
                                    ));
                                  },
                                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                                  tooltip: 'delete'.tr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ) : Center(child: Text('no_delivery_man_found'.tr)) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
