// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_shimmer_widget.dart';
import 'package:tamam_business/util/dimensions.dart';

class BrandListShimmer extends StatelessWidget {
  const BrandListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.5 : 0.2)),
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: const CustomShimmerWidget(height: 65, width: 65),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmerWidget(height: 15, width: 200),
                  SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomShimmerWidget(height: 10, width: 80),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
