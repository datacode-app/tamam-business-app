// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/business/domain/models/package_model.dart';
import 'package:tamam_business/features/business/widgets/curve_clipper_widget.dart';
import 'package:tamam_business/features/business/widgets/package_widget.dart';
import 'package:tamam_business/helper/price_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final int index;
  final Packages package;
  final Color color;
  const SubscriptionCardWidget({super.key, required this.index, required this.package, required this.color});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(children: [

      ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
        child: Stack(
          children: [

            ClipPath(
              clipper: CurveClipper(),
              child: Container(
              color: color.withAlpha((0.3 * 255).round()),
              height: 140.0,
              ),
            ),

            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                color: color.withAlpha((0.2 * 255).round()),
                height: 158.0,
              ),
            ),

            ClipPath(
              clipper: CurveClipper(),
              child: Stack(
                children: [
                  SizedBox(
                    height: 120, width: size.width,
                    child: Container(
                      color: color.withAlpha((1 * 255).round()),
                      height: 120.0,
                    ),
                  ),
                  Positioned(
                    child: SizedBox(
                      height: 120, width: size.width,
                      child: CustomPaint(
                        painter: const CardPaint(color: Colors.white),
                        child: Center(
                          child: Text(
                            '${package.packageName}',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ]),
      ),

      const SizedBox(height: Dimensions.paddingSizeDefault),

      Text(
        PriceConverterHelper.convertPrice(package.price),
        style: robotoBold.copyWith(fontSize: 35, color: color),
      ),

      Text('${package.validity} ' 'days'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Divider(color: color, indent: 70, endIndent: 70, thickness: 2),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        PackageWidget(title: '${'max_order'.tr} (${package.maxOrder})'),

        PackageWidget(title: '${'max_product'.tr} (${package.maxProduct})'),

        package.pos != 0 ? PackageWidget(title: 'pos'.tr) : const SizedBox(),

        package.mobileApp != 0 ? PackageWidget(title: 'mobile_app'.tr) : const SizedBox(),

        package.chat != 0 ? PackageWidget(title: 'chat'.tr) : const SizedBox(),

        package.review != 0 ? PackageWidget(title: 'review'.tr) : const SizedBox(),

        package.selfDelivery != 0 ? PackageWidget(title: 'self_delivery'.tr) : const SizedBox(),
      ]),

    ]);
  }
}
