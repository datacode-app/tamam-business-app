// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/custom_image_widget.dart';
import 'package:tamam_business/common/widgets/custom_text_field_widget.dart';
import 'package:tamam_business/common/widgets/rating_bar_widget.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/features/store/controllers/store_controller.dart';
import 'package:tamam_business/features/store/domain/models/review_model.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class ReviewReplyScreen extends StatefulWidget {
  final bool isGiveReply;
  final ReviewModel review;
  final bool? storeReviewReplyStatus;
  const ReviewReplyScreen({super.key, required this.isGiveReply, required this.review, this.storeReviewReplyStatus = false});

  @override
  State<ReviewReplyScreen> createState() => _ReviewReplyScreenState();
}

class _ReviewReplyScreenState extends State<ReviewReplyScreen> {

  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.isGiveReply) {
      _replyController.text = widget.review.reply ?? '';
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        titleWidget: Column(children: [

          Text(!widget.storeReviewReplyStatus! ? 'review'.tr : widget.storeReviewReplyStatus! && widget.isGiveReply ? 'review_reply'.tr : 'update_reply'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color)),

          Text('# ${widget.review.reviewId}', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault)),

        ]),
      ),
      body: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImageWidget(
                        image: '${widget.review.itemImageFullUrl}',
                        height: 60, width: 60, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(widget.review.itemName ?? '', style: robotoBold, overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        RatingBarWidget(rating: widget.review.rating?.toDouble(), ratingCount: null, size: 20),
                      ]),
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(widget.review.customerName ?? '', style: robotoBold),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(widget.review.comment ?? '', style: robotoRegular),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  widget.storeReviewReplyStatus! ? widget.isGiveReply ? CustomTextFieldWidget(
                    controller: _replyController,
                    hintText: 'write_your_reply_here'.tr,
                    showLabelText: false,
                    borderColor: Theme.of(context).hintColor,
                    maxLines: 4,
                  ) : Container(
                    width: context.width,
                    height: 120,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round())),
                    ),
                    child: Text(widget.review.reply ?? '', style: robotoRegular, maxLines: 5, overflow: TextOverflow.ellipsis),
                  ) : const SizedBox(),

                ]),
              ),
            ),
          ),

          widget.storeReviewReplyStatus! ? Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withAlpha((0.2 * 255).round()), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
            ),
            child: !storeController.isLoading ? CustomButtonWidget(
              onPressed: () {
                if(widget.isGiveReply) {
                  storeController.updateReply(widget.review.id!, _replyController.text);
                }else {
                  Get.offNamed(RouteHelper.getReviewReplyRoute(isGiveReply: true, review: widget.review, storeReviewReplyStatus: Get.find<SplashController>().configModel!.storeReviewReply!));
                }
              },
              buttonText: widget.isGiveReply ? 'send_reply'.tr : 'update_review'.tr,
              radius: Dimensions.radiusDefault,
            ) : const Center(child: CircularProgressIndicator()),
          ) : const SizedBox(),

        ]);
      }),
    );
  }
}
