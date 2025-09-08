// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/deliveryman/controllers/deliveryman_controller.dart';
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class DriverScheduleScreen extends StatefulWidget {
  final int driverId;
  const DriverScheduleScreen({super.key, required this.driverId});

  @override
  State<DriverScheduleScreen> createState() => _DriverScheduleScreenState();
}

class _DriverScheduleScreenState extends State<DriverScheduleScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<DeliveryManController>().getDriverSchedule(widget.driverId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'driver_schedule'.tr),
      body: GetBuilder<DeliveryManController>(builder: (deliveryManController) {
        return deliveryManController.driverSchedules != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return buildScheduleWidget(
                            context, index, deliveryManController);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomButtonWidget(
                      onPressed: () {
                        deliveryManController.setDriverSchedule(widget.driverId,
                            deliveryManController.driverSchedules!);
                      },
                      buttonText: 'save_changes'.tr,
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget buildScheduleWidget(BuildContext context, int day,
      DeliveryManController deliveryManController) {
    final schedule = deliveryManController.driverSchedules!.firstWhere(
        (element) => element.day == day,
        orElse: () => DeliveryManScheduleModel(
            day: day, startTime: '00:00', endTime: '00:00'));
    TimeOfDay startTime = DateConverter.stringToTimeOfDay(schedule.startTime!);
    TimeOfDay endTime = DateConverter.stringToTimeOfDay(schedule.endTime!);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              spreadRadius: 1,
              blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(DateConverter.getDayName(day), style: robotoRegular)),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                  context: context, initialTime: startTime);
              if (picked != null) {
                setState(() {
                  startTime = picked;
                });
                deliveryManController.updateDriverSchedule(
                    day,
                    DateConverter.timeOfDayToString(startTime),
                    DateConverter.timeOfDayToString(endTime));
              }
            },
            child: Text(DateConverter.timeOfDayToString(startTime),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor)),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          const Text('-'),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked =
                  await showTimePicker(context: context, initialTime: endTime);
              if (picked != null) {
                setState(() {
                  endTime = picked;
                });
                deliveryManController.updateDriverSchedule(
                    day,
                    DateConverter.timeOfDayToString(startTime),
                    DateConverter.timeOfDayToString(endTime));
              }
            },
            child: Text(DateConverter.timeOfDayToString(endTime),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }
}
