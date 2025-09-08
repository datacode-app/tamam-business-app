// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/deliveryman/domain/models/delivery_man_schedule_model.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class ScheduleWidget extends StatefulWidget {
  final int day;
  final List<DeliveryManScheduleModel> schedules;
  final Function(int day, String start, String end) onTimeChanged;

  const ScheduleWidget(
      {super.key,
      required this.day,
      required this.schedules,
      required this.onTimeChanged});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedules.firstWhere(
        (element) => element.day == widget.day,
        orElse: () => DeliveryManScheduleModel(
            day: widget.day, startTime: '00:00', endTime: '00:00'));
    _startTime = DateConverter.stringToTimeOfDay(schedule.startTime!);
    _endTime = DateConverter.stringToTimeOfDay(schedule.endTime!);
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text(DateConverter.getDayName(widget.day),
                  style: robotoRegular)),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                  context: context, initialTime: _startTime);
              if (picked != null) {
                setState(() {
                  _startTime = picked;
                });
                widget.onTimeChanged(
                    widget.day,
                    DateConverter.timeOfDayToString(_startTime),
                    DateConverter.timeOfDayToString(_endTime));
              }
            },
            child: Text(DateConverter.timeOfDayToString(_startTime),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor)),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          const Text('-'),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked =
                  await showTimePicker(context: context, initialTime: _endTime);
              if (picked != null) {
                setState(() {
                  _endTime = picked;
                });
                widget.onTimeChanged(
                    widget.day,
                    DateConverter.timeOfDayToString(_startTime),
                    DateConverter.timeOfDayToString(_endTime));
              }
            },
            child: Text(DateConverter.timeOfDayToString(_endTime),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }
}
