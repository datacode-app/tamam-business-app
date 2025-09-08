// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class InfoWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String? data;
  const InfoWidget({super.key, required this.icon, required this.title, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      
      Image.asset(icon, height: 20, width: 20, color: Theme.of(context).disabledColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Text('$title:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor)),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Flexible(child: Text(data!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
      
    ]);
  }
}
