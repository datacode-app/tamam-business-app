// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_asset_image_widget.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class AdsCard extends StatelessWidget {
  final String img;
  final String title;
  final String subTitle;
  final TextStyle? subtitleTextStyle;
  final MainAxisAlignment mainAxisAlignment;
  const AdsCard({super.key, required this.img, required this.title, required this.subTitle, this.mainAxisAlignment = MainAxisAlignment.start,  this.subtitleTextStyle});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomAssetImageWidget(img, height: 15, width: 15),
        const SizedBox(width:Dimensions.paddingSizeSmall),

        Expanded(
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Flexible(
                child: Text(title.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall + 1,
                    color:Theme.of(context).textTheme.bodyLarge!.color!.withAlpha((0.65 * 255).round()),
                  ),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(subTitle,
                style: subtitleTextStyle ?? robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha((0.65 * 255).round()),
                ),
                maxLines: 2, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
