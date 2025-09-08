// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';

class CustomIconLayout extends StatelessWidget {
  final double height;
  final double width;
  final double? paddingSize;
  final IconData? icon;
  final String? iconImage;

  const CustomIconLayout({super.key, this.height = 10, this.width = 10, this.icon, this.iconImage, this.paddingSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withAlpha((0.2 * 255).round()), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      padding: EdgeInsets.all(paddingSize ?? Dimensions.paddingSizeExtraSmall),
      child: iconImage != null ? Image.asset(iconImage!, height: height, width: width) : Icon(icon, size: 20),
    );
  }
}
