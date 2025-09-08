// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class DisbursementMenuScreen extends StatelessWidget {
  const DisbursementMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBarWidget(title: 'disbursement'.tr),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(children: [

              SubMenuCardWidget(title: 'view_disbursement_history'.tr, image: Images.disbursementIcon, route: () => Get.toNamed(RouteHelper.getDisbursementRoute())),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              SubMenuCardWidget(title: 'disbursement_method_setup'.tr, image: Images.transactionIcon, route: () => Get.toNamed(RouteHelper.getWithdrawMethodRoute())),

            ]),
          ),
        )
    );
  }
}

class SubMenuCardWidget extends StatelessWidget {
  final String title;
  final String image;
  final void Function() route;
  const SubMenuCardWidget({super.key, required this.title, required this.image, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route,
      child: Container(
        height: 80, width: context.width,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).primaryColor.withAlpha((0.03 * 255).round()),
          border: Border.all(width: 1, color: Theme.of(context).primaryColor.withAlpha((0.3 * 255).round())),
        ),
        child: Row(children: [

          Image.asset(image, width: 40, height: 40, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(title, style: robotoMedium),

        ]),
      ),
    );
  }
}
