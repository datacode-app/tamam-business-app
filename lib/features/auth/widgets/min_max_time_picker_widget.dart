// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class MinMaxTimePickerWidget extends StatefulWidget {
  final List<String> times;
  final Function(int index) onChanged;
  final int initialPosition;
  const MinMaxTimePickerWidget({super.key, required this.times, required this.onChanged, required this.initialPosition});

  @override
  State<MinMaxTimePickerWidget> createState() => _MinMaxTimePickerWidgetState();
}

class _MinMaxTimePickerWidgetState extends State<MinMaxTimePickerWidget> {
  int selectedIndex = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: 0.3,
          initialPage: widget.initialPosition,
          autoPlayInterval: const Duration(seconds: 7),
          onPageChanged: (index, reason) {
            setState(() {
              selectedIndex = index;
            });
            widget.onChanged(index);
          },
          scrollDirection: Axis.vertical,
        ),
        itemCount: widget.times.length,
        itemBuilder: (context, index, _) {
          return Container(
            decoration: BoxDecoration(
              color: selectedIndex == index ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()) : Colors.transparent,
            ),
            child: Center(child: Text(
              widget.times[index].toString(),
              style: selectedIndex == index ? robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            )),
          );
        },
      ),
    );
  }
}
