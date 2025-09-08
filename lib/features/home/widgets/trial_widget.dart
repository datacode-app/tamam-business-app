// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_ink_well_widget.dart';
import 'package:tamam_business/features/business/controllers/business_controller.dart';
import 'package:tamam_business/features/profile/domain/models/profile_model.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/helper/remote_config_helper.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class TrialWidget extends StatefulWidget {
  final Subscription subscription;
  const TrialWidget({super.key, required this.subscription});

  @override
  State<TrialWidget> createState() => _TrialWidgetState();
}

class _TrialWidgetState extends State<TrialWidget> {
  bool _showButton = false;
  @override
  Widget build(BuildContext context) {
    int remainingDays = DateConverter.differenceInDaysIgnoringTime(
        DateTime.parse(widget.subscription.expiryDate!), DateTime.now());

    double remainingPercentage = 1 -
        (((widget.subscription.validity! - remainingDays) /
                    widget.subscription.validity!) *
                100) /
            100;
    return GetBuilder<BusinessController>(builder: (businessController) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 60,
        width: businessController.freeTrialExpand ? 320 : 180,
        decoration: const BoxDecoration(
          color: Color(0xffFF6D6D),
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(Dimensions.radiusDefault)),
        ),
        child: Row(children: [
          const SizedBox(width: Dimensions.fontSizeExtraSmall),

          CustomInkWellWidget(
            onTap: () =>
                businessController.changeFreeTrialExpandStatus().then((value) {
              _showButton = false;
              Future.delayed(const Duration(milliseconds: 400), () {
                _showButton = true;
                setState(() {});
              });
            }),
            child: Icon(
              businessController.freeTrialExpand
                  ? Icons.arrow_forward_ios
                  : Icons.arrow_back_ios,
              color: Theme.of(context).cardColor,
            ),
          ),
          // const SizedBox(width: Dimensions.fontSizeExtraSmall),

          SizedBox(
            height: 40,
            width: 40,
            child: Stack(children: [
              Center(
                child: CircularProgressIndicator(
                  value: remainingPercentage,
                  color: Theme.of(context).cardColor,
                  backgroundColor:
                      Theme.of(context).cardColor.withAlpha((0.3 * 255).round()),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '$remainingDays',
                  style: robotoBold.copyWith(
                      color: Theme.of(context).cardColor,
                      fontSize: Dimensions.fontSizeLarge),
                ),
              ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Flexible(
            child: Text(
              'days_left_in_free_trial'.tr,
              style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),

          businessController.freeTrialExpand
              // 🚨 APPLE COMPLIANCE: Only show "Choose Plan" if remote config allows subscription management
              ? (RemoteConfigHelper.isSubscriptionManagementEnabled() 
                  ? Visibility(
                      visible: _showButton,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(RouteHelper.getMySubscriptionRoute());
                          businessController
                              .changeFreeTrialExpandStatus()
                              .then((value) {
                            _showButton = false;
                            Future.delayed(const Duration(milliseconds: 400), () {
                              _showButton = true;
                              setState(() {});
                            });
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Text(
                              'choose_plan'.tr,
                              style: robotoBold.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color),
                            ),
                            // const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            const Icon(
                              Icons.arrow_forward_outlined,
                              color: Colors.green,
                            ),
                          ]),
                        ),
                      ),
                    )
                  : const SizedBox()) // Hide when subscription management is disabled
              : const SizedBox(),
        ]),
      );
    });
  }
}
