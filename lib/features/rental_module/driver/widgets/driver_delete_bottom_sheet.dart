// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_asset_image_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/rental_module/driver/controllers/driver_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class DriverDeleteBottomSheet extends StatelessWidget {
  final int driverId;
  const DriverDeleteBottomSheet({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverController>(builder: (driverController) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 40),

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),

            IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).disabledColor.withAlpha((0.6 * 255).round())),
              onPressed: () => Navigator.pop(context),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [
              const CustomAssetImageWidget(Images.driverDeleteConformationIcon, height: 60, width: 60),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('are_you_sure'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'driver_delete_confirmation'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Expanded(
                  child: CustomButtonWidget(
                    onPressed: () => Navigator.pop(context),
                    buttonText: 'no'.tr,
                    color: Theme.of(context).disabledColor.withAlpha((0.2 * 255).round()),
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: CustomButtonWidget(
                    isLoading: driverController.isLoading,
                    onPressed: () {
                      driverController.deleteDriver(driverId: driverId).then((value) {
                        Navigator.pop(Get.context!);
                      });
                    },
                    buttonText: 'yes'.tr,
                  ),
                ),

              ]),
            ]),
          ),

        ]),
      );
    });
  }
}
