// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/rating_bar_widget.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel review;
  final bool hasDivider;
  final bool fromStore;
  const ReviewWidget(
      {super.key,
      required this.review,
      required this.hasDivider,
      required this.fromStore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
      child: Container(
        width: context.width * 0.7,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            fromStore
                ? review.itemName!
                : review.customer != null
                    ? '${review.customer!.fName} ${review.customer!.lName}'
                    : 'customer_not_found'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          RatingBarWidget(rating: review.rating!.toDouble(), ratingCount: null),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(DateConverter.convertDateToDate(review.createdAt!),
              style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeSmall)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            review.comment ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withAlpha((0.7 * 255).round()),
                fontSize: Dimensions.fontSizeSmall),
          ),
        ]),
      ),
    );
  }
}
