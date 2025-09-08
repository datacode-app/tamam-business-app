// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class TitleTagWidget extends StatelessWidget {
  final String title;
  const TitleTagWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35, width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),

      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha((0.05 * 255).round()),
        border: Border.symmetric(horizontal: BorderSide(color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()))),
      ),
      child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
    );
  }
}
