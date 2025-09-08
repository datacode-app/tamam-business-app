// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/common/widgets/custom_image_widget.dart';
import 'package:tamam_business/common/widgets/discount_tag_widget.dart';
import 'package:tamam_business/common/widgets/not_available_widget.dart';
import 'package:tamam_business/common/widgets/rating_bar_widget.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/features/store/controllers/store_controller.dart';
import 'package:tamam_business/features/store/domain/models/item_model.dart';
import 'package:tamam_business/features/store/screens/item_details_screen.dart';
import 'package:tamam_business/features/store/widgets/update_stock_bottom_sheet.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/helper/price_converter_helper.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class ItemWidget extends StatelessWidget {
  final Item item;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool fromPending;
  const ItemWidget(
      {super.key,
      required this.item,
      required this.index,
      required this.length,
      this.inStore = false,
      this.isCampaign = false,
      this.fromPending = false});

  @override
  Widget build(BuildContext context) {
    double? discount = (item.storeDiscount == 0 || isCampaign)
        ? item.discount
        : item.storeDiscount;
    String? discountType =
        (item.storeDiscount == 0 || isCampaign) ? item.discountType : 'percent';
    bool isAvailable = DateConverter.isAvailable(
        item.availableTimeStarts, item.availableTimeEnds);

    return InkWell(
      onTap: () {
        if (fromPending) {
          Get.toNamed(RouteHelper.getPendingItemDetailsRoute(item.id!),
              arguments:
                  ItemDetailsScreen(product: item));
        } else {
          Get.toNamed(RouteHelper.getItemDetailsRoute(item),
              arguments: ItemDetailsScreen(product: item));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[Get.isDarkMode ? 800 : 300]!,
                spreadRadius: 1,
                blurRadius: 5)
          ],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImageWidget(
                    image: '${item.imageFullUrl}',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                DiscountTagWidget(
                  discount: discount,
                  discountType: discountType,
                  freeDelivery: false,
                ),
                isAvailable ? const SizedBox() : const NotAvailableWidget(),
              ]),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name!,
                        style: robotoMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      RatingBarWidget(
                        rating: item.avgRating,
                        size: 13,
                        ratingCount: item.ratingCount,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              PriceConverterHelper.convertPrice(item.price),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .stock! &&
                                  !isCampaign)
                              ? Text('${item.stock} ${'in_stock'.tr}',
                                  style: robotoRegular.copyWith(
                                      fontSize: 10))
                              : const SizedBox(),
                          discount! > 0
                              ? Flexible(
                                  child: Text(
                                    PriceConverterHelper.convertPrice(
                                        PriceConverterHelper.getStartingPrice(item)),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && !isCampaign) ? Text(
                      //   '${item.stock} ${'in_stock'.tr}',
                      //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      // ) : SizedBox(),
                    ]),
              ),
            ]),
          )),
          (Get.find<SplashController>()
                      .configModel!
                      .moduleConfig!
                      .module!
                      .stock! &&
                  !isCampaign)
              ? GetBuilder<StoreController>(builder: (storeController) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'daily_recommended_quantity'.tr}:',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                        Row(children: [
                          Text(
                            '${item.maxOrderQuantity}',
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          InkWell(
                            onTap: () => Get.bottomSheet(
                                UpdateStockBottomSheet(
                                    item: item,
                                    onSuccess: (success) {
                                      if (success) {
                                        Get.find<StoreController>().getItemList('1', 'all');
                                      }
                                    }),
                                isScrollControlled: true),
                            child: Icon(Icons.edit,
                                size: 20, color: Colors.blue.withAlpha((0.5 * 255).round())),
                          ),
                        ]),
                      ]);
                })
              : const SizedBox(),
          !fromPending
              ? GetBuilder<StoreController>(builder: (storeController) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (Get.find<ProfileController>()
                            .profileModel!
                            .stores![0]
                            .itemSection!)
                          ToggleButtons(
                            borderColor: Theme.of(context).primaryColor,
                            selectedBorderColor: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            // disabledColor: Theme.of(context).disabledColor,
                            fillColor:
                                Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                            onPressed: (int index) {
                              storeController.toggleRecommendedProduct(item.id);
                            },
                            isSelected: [
                              item.recommendedStatus == 1 ? true : false
                            ],
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall),
                                child: Text('recommended'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall)),
                              ),
                            ],
                          ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        if (Get.find<ProfileController>()
                            .profileModel!
                            .stores![0]
                            .itemSection!)
                          ToggleButtons(
                            borderColor: Theme.of(context).primaryColor,
                            selectedBorderColor: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            // disabledColor: Theme.of(context).disabledColor,
                            fillColor:
                                Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                            onPressed: (int index) {
                              storeController.toggleAvailable(item.id);
                            },
                            isSelected: [item.status == 1 ? true : false],
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall),
                                child: Text(
                                    item.status == 1
                                        ? 'active'.tr
                                        : 'inactive'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall)),
                              ),
                            ],
                          ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        InkWell(
                          onTap: () {
                            if (fromPending) {
                              Get.toNamed(
                                  RouteHelper.getPendingItemDetailsRoute(
                                      item.id!));
                            } else {
                              Get.toNamed(RouteHelper.getAddItemRoute(item));
                            }
                          },
                          child: const Icon(Icons.edit, size: 20),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        InkWell(
                          onTap: () {
                            Get.dialog(ConfirmationDialogWidget(
                              icon: Images.warning,
                              description:
                                  'are_you_sure_want_to_delete_this_item'.tr,
                              onYesPressed: () => Get.find<StoreController>()
                                  .deleteItem(item.id, pendingItem: fromPending),
                            ));
                          },
                          child: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                        ),
                      ]);
                })
              : const SizedBox(),
        ]),
      ),
    );
  }
}
