// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';
import 'package:tamam_business/common/widgets/custom_asset_image_widget.dart';

class NoDataScreen extends StatelessWidget {
  final String? text;
  final double? height;
  const NoDataScreen({super.key, required this.text, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Get.height * 0.7,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          const CustomAssetImageWidget(Images.adsListImage, height: 70, width: 70),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            text ?? 'no_data_available'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}