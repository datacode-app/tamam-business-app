// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/custom_image_widget.dart';
import 'package:tamam_business/features/campaign/controllers/campaign_controller.dart';
import 'package:tamam_business/features/campaign/domain/models/campaign_model.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final int id;
  final bool fromNotification;
  const CampaignDetailsScreen(
      {super.key, required this.id, this.fromNotification = false});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  CampaignModel? campaignModel;

  @override
  void initState() {
    super.initState();
    if (Get.find<CampaignController>().campaignList == null) {
      Get.find<CampaignController>().getCampaignList();
    }
  }

  _matchCampaign() {
    for (CampaignModel campaign
        in Get.find<CampaignController>().campaignList!) {
      if (campaign.id == widget.id) {
        return campaign;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<CampaignController>(builder: (campaignController) {
        if (campaignController.campaignList != null) {
          campaignModel = _matchCampaign();
        }

        return campaignController.campaignList != null
            ? campaignController.campaignList!.isNotEmpty
                ? Column(children: [
                    Expanded(
                        child: CustomScrollView(slivers: [
                      SliverAppBar(
                        expandedHeight: 230,
                        toolbarHeight: 50,
                        pinned: true,
                        floating: false,
                        backgroundColor: Theme.of(context).primaryColor,
                        leading: IconButton(
                          icon: Icon(Icons.chevron_left,
                              color: Theme.of(context).cardColor),
                          onPressed: () => Get.back(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: CustomImageWidget(
                            fit: BoxFit.cover,
                            placeholder: Images.restaurantCover,
                            image: campaignModel?.imageFullUrl ?? '',
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: Center(
                              child: Container(
                        width: 1170,
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        color: Theme.of(context).cardColor,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  child: CustomImageWidget(
                                    image: '${campaignModel?.imageFullUrl}',
                                    height: 40,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(
                                        campaignModel?.title ?? '',
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeLarge),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        campaignModel?.description ?? '',
                                        style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .disabledColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ])),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              Row(children: [
                                Expanded(
                                  child: Column(children: [
                                    Text(
                                      'date'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    Text(
                                      '${DateConverter.convertDateToDate(campaignModel!.availableDateStarts!)} - ${DateConverter.convertDateToDate(campaignModel!.availableDateEnds!)}',
                                      style: robotoMedium,
                                    ),
                                  ]),
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Expanded(
                                  child: Column(children: [
                                    Text(
                                      'daily_time'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    Text(
                                      '${DateConverter.stringToReadableTime(campaignModel!.startTime!)} - ${DateConverter.stringToReadableTime(campaignModel!.endTime!)}',
                                      style: robotoMedium,
                                    ),
                                  ]),
                                ),
                              ]),
                            ]),
                      ))),
                    ])),
                    CustomButtonWidget(
                      buttonText: campaignModel!.isJoined!
                          ? 'leave_now'.tr
                          : 'join_now'.tr,
                      color: campaignModel!.isJoined!
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).primaryColor,
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      onPressed: () {
                        Get.dialog(ConfirmationDialogWidget(
                          icon: Images.warning,
                          description: campaignModel!.isJoined!
                              ? 'are_you_sure_to_leave'.tr
                              : 'are_you_sure_to_join'.tr,
                          onYesPressed: () {
                            if (campaignModel!.isJoined!) {
                              Get.find<CampaignController>()
                                  .leaveCampaign(campaignModel?.id, true);
                            } else {
                              Get.find<CampaignController>()
                                  .joinCampaign(campaignModel?.id, true);
                            }
                          },
                        ));
                      },
                    ),
                  ])
                : Center(child: Text('no_campaign_available'.tr))
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
