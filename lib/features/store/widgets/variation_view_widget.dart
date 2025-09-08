// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/store/domain/models/item_model.dart';
import 'package:tamam_business/helper/price_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class VariationView extends StatelessWidget {
  final Item item;
  final bool? stock;
  const VariationView({super.key, required this.item, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      (item.variations != null && item.variations!.isNotEmpty) ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withAlpha((0.3 * 255).round()), blurRadius: 10)],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('variations'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          ListView.builder(
            itemCount: item.variations!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Row(children: [

                Text('${item.variations![index].type!}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  PriceConverterHelper.convertPrice(item.variations![index].price),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                SizedBox(width: stock! ? Dimensions.paddingSizeExtraSmall : 0),
                stock! ? Text(
                  '(${item.variations![index].stock})',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ) : const SizedBox(),

              ]);
            },
          ),
        ]),
      ) : const SizedBox(),

      SizedBox(height: (item.variations != null && item.variations!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),
    ]);
  }
}
