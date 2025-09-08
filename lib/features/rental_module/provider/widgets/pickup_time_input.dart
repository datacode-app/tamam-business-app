// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_drop_down_button.dart.dart';
import 'package:tamam_business/features/rental_module/provider/controllers/provider_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class PickupTimeInput extends StatefulWidget {
  final TextEditingController minTimeController;
  final TextEditingController maxTimeController;
  const PickupTimeInput({super.key, required this.minTimeController, required this.maxTimeController});

  @override
  State<PickupTimeInput> createState() => _PickupTimeInputState();
}

class _PickupTimeInputState extends State<PickupTimeInput> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderController>(builder: (providerController) {
      return Stack(clipBehavior: Clip.none, children: [

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).disabledColor.withAlpha((0.2 * 255).round())),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: widget.minTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  hintText: 'min_20'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  border: InputBorder.none,
                ),
              ),
            ),

            Container(
              height: 25,
              width: 1,
              color: Theme.of(context).disabledColor.withAlpha((0.2 * 255).round()),
            ),

            Expanded(
              child: TextField(
                controller: widget.maxTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  hintText: 'max_30'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  border: InputBorder.none,
                ),
              ),
            ),

            Expanded(
              child: CustomDropdownButton(
                dropdownMenuItems: providerController.durations.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Text(item.value, style: robotoRegular),
                  );
                }).toList(),
                isBorder: false,
                borderRadius: 0,
                backgroundColor: Theme.of(context).disabledColor.withAlpha((0.2 * 255).round()),
                onChanged: (String? value) {
                  providerController.setSelectedDuration(value!);
                  String durationKey = providerController.durations.firstWhere((element) => element.value == value).key;
                  providerController.setSelectedDurationKey(durationKey);
                },
                selectedValue: providerController.selectedDuration,
              ),
            ),
          ]),
        ),

        Positioned(
          left: 10, top: -15,
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            padding: const EdgeInsets.all(5),
            child: Text('approx_pickup_time'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
          ),
        ),

      ]);
    });
  }
}
