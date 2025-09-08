// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class CustomTimePickerWidget extends StatefulWidget {
  final String title;
  final String? time;
  final Function(String) onTimeChanged;
  const CustomTimePickerWidget(
      {super.key,
      required this.title,
      required this.time,
      required this.onTimeChanged});

  @override
  State<CustomTimePickerWidget> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePickerWidget> {
  String? _myTime;

  @override
  void initState() {
    super.initState();

    _myTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: () async {
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: _myTime != null
                    ? DateConverter.stringToTimeOfDay(_myTime!).hour
                    : 0,
                minute: _myTime != null
                    ? DateConverter.stringToTimeOfDay(_myTime!).minute
                    : 0),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: false),
                child: child!,
              );
            },
          );
          if (time != null) {
            setState(() {
              _myTime = DateConverter.timeOfDayToString(time);
            });
            widget.onTimeChanged(_myTime!);
          }
        },
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                  color: Theme.of(context).disabledColor, width: 0.5),
            ),
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Expanded(
                  child: Text(
                _myTime != null
                    ? DateConverter.stringToReadableTime(_myTime!)
                    : ' - -  : - - ${'min'.tr}',
                style: robotoRegular.copyWith(
                    color: _myTime != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).disabledColor,
                    fontSize: Dimensions.fontSizeDefault),
              )),
              Icon(Icons.access_time_filled,
                  size: 20, color: Theme.of(context).primaryColor),
            ]),
          ),
          Positioned(
            left: 10,
            top: -15,
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              padding: const EdgeInsets.all(5),
              child: Text(widget.title,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ),
          ),
        ]),
      ),
    ]);
  }
}
