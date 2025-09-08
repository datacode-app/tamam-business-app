// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/blocked_feature_widget.dart';
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/auth/controllers/auth_controller.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/features/subscription/controllers/subscription_controller.dart';
import 'package:tamam_business/features/subscription/widgets/change_subscription_plan_bottom_sheet.dart';
import 'package:tamam_business/features/subscription/widgets/subscription_details_widget.dart';
import 'package:tamam_business/features/subscription/widgets/transaction_widget.dart';
import 'package:tamam_business/helper/remote_config_helper.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class MySubscriptionScreen extends StatefulWidget {
  final bool fromNotification;
  const MySubscriptionScreen({super.key, this.fromNotification = false});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> with TickerProviderStateMixin {

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<SubscriptionController>().getProfile(Get.find<ProfileController>().profileModel);
    } else {
      Get.find<SubscriptionController>().getProfile(Get.find<AuthController>().profileModel);
    }

    Get.find<SubscriptionController>().initSetDate();
    Get.find<SubscriptionController>().setOffset(1);

    Get.find<SubscriptionController>().getSubscriptionTransactionList(
      offset: Get.find<SubscriptionController>().offset.toString(),
      from: Get.find<SubscriptionController>().from, to: Get.find<SubscriptionController>().to,
      searchText: Get.find<SubscriptionController>().searchText,
    );
    _loadTrialWidgetShow();
  }

  Future<void> _loadTrialWidgetShow() async {
    await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.mySubscription);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Check if business plan features are enabled via Remote Config
  /// Returns true if feature should be shown, false if blocked
  bool _checkBusinessPlanFeature({required bool isViewOnly}) {
    if (isViewOnly) {
      return RemoteConfigHelper.isBusinessPlanViewEnabled();
    } else {
      return RemoteConfigHelper.isBusinessPlanChangesEnabled();
    }
  }

  /// Show blocked business plan feature
  void _showBlockedBusinessPlan({bool isChangeAction = false}) {
    BlockedFeatureBottomSheet.show(
      context,
      featureName: 'business_plan',
      customTitle: isChangeAction ? 'change_business_plan_not_available'.tr : 'business_plan_not_available'.tr,
      customDescription: isChangeAction 
        ? 'business_plan_change_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr
        : 'business_plan_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if any business plan features are available
    bool anyBusinessPlanEnabled = RemoteConfigHelper.isAnyBusinessPlanFeatureEnabled();
    
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {

      bool businessIsCommission = subscriptionController.profileModel!.stores![0].storeBusinessModel == 'commission';
      bool businessIsNone = subscriptionController.profileModel!.stores![0].storeBusinessModel == 'none';
      bool businessIsUnsubscribed = subscriptionController.profileModel!.stores![0].storeBusinessModel == 'unsubscribed';

      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) {
          Get.find<ProfileController>().trialWidgetShow(route: '');
          if(widget.fromNotification && !didPop) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        },
        child: Scaffold(
          appBar: CustomAppBarWidget(title: 'my_business_plan'.tr, onTap: () {
            Get.find<ProfileController>().trialWidgetShow(route: '');
            if(widget.fromNotification){
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }else{
              Get.back();
            }
          }),
          body: subscriptionController.profileModel != null ? (businessIsCommission && !subscriptionController.profileModel!.subscriptionTransactions!) ? Column(children: [

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).disabledColor.withAlpha((0.03 * 255).round()),
                  ),
                  child: Column(children: [

                    Text(
                      'commission_base_plan'.tr,
                      style: robotoBold.copyWith(color: const Color(0xff006161), fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      '${Get.find<ProfileController>().profileModel != null && Get.find<ProfileController>().profileModel!.stores?[0].comission != null && Get.find<ProfileController>().profileModel!.stores![0].comission! > 0
                          ? Get.find<ProfileController>().profileModel!.stores![0].comission!
                          :  Get.find<SplashController>().configModel?.adminCommission} %',
                      style: robotoBold.copyWith(color: Colors.teal, fontSize: 24),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.width * 0.15),
                      child: Text(
                        "${'vendor_will_pay'.tr} ${Get.find<SplashController>().configModel!.adminCommission}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel!.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha((0.7 * 255).round()), height: 2), textAlign: TextAlign.center,
                      ),
                    )

                  ]),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                buttonText: 'change_business_plan'.tr,
                radius: Dimensions.radiusDefault,
                height: 55,
                onPressed: () {
                  // Check remote config before allowing business plan changes
                  if (_checkBusinessPlanFeature(isViewOnly: false)) {
                    showCustomBottomSheet(
                      child: ChangeSubscriptionPlanBottomSheet(businessIsCommission: businessIsCommission),
                    );
                  } else {
                    _showBlockedBusinessPlan(isChangeAction: true);
                  }
                },
              ),
            ),

          ]) : (businessIsNone || (businessIsUnsubscribed && (subscriptionController.profileModel?.subscription == null))) ? Column(children: [

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).colorScheme.error.withAlpha((0.6 * 255).round()),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'you_have_no_business_plan'.tr,
                          style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.width * 0.05),
                          child: Text(
                            "chose_a_business_plan_from_the_list_so_that_you_get_more_options_to_join_the_business_for_the_growth_and_success".tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor, height: 2), textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                ]),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                buttonText: (businessIsNone || (businessIsUnsubscribed && (subscriptionController.profileModel?.subscription == null))) ? 'chose_business_plan'.tr : 'change_business_plan'.tr,
                radius: Dimensions.radiusDefault,
                height: 55,
                onPressed: () {
                  // Check remote config before allowing business plan selection/changes
                  bool isChoosingPlan = (businessIsNone || (businessIsUnsubscribed && (subscriptionController.profileModel?.subscription == null)));
                  if (isChoosingPlan) {
                    // Check plan selection during registration
                    if (RemoteConfigHelper.isPlanSelectionRegistrationEnabled()) {
                      showCustomBottomSheet(
                        child: ChangeSubscriptionPlanBottomSheet(businessIsCommission: businessIsCommission),
                      );
                    } else {
                      _showBlockedBusinessPlan(isChangeAction: false);
                    }
                  } else {
                    // Check plan changes
                    if (_checkBusinessPlanFeature(isViewOnly: false)) {
                      showCustomBottomSheet(
                        child: ChangeSubscriptionPlanBottomSheet(businessIsCommission: businessIsCommission),
                      );
                    } else {
                      _showBlockedBusinessPlan(isChangeAction: true);
                    }
                  }
                },
              ),
            ),

          ]) : Column(children: [

            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
              tabs: [
                Tab(text: businessIsCommission ? 'plan_details'.tr : 'subscription_details'.tr),
                Tab(text: 'transaction'.tr),
              ],
            ),

            Expanded(child: TabBarView(
              controller: _tabController,
              children: [
                SubscriptionDetailsWidget(subscriptionController: subscriptionController),
                const TransactionWidget(),
              ],
            )),

          ]) : const Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }
}
