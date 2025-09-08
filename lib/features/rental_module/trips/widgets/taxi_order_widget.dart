// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/rental_module/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/features/rental_module/trips/controllers/trip_controller.dart';
import 'package:tamam_business/features/rental_module/trips/domain/models/trip_list_model.dart';
import 'package:tamam_business/features/rental_module/trips/screens/trip_details_screen.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/helper/price_converter_helper.dart';
import 'package:tamam_business/helper/string_extensions.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class TaxiOrderWidget extends StatelessWidget {
  final Trips? trips;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool fromDriverDetails;
  const TaxiOrderWidget(
      {super.key,
      this.trips,
      required this.index,
      required this.isExpanded,
      required this.onToggle,
      this.fromDriverDetails = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TripController>(builder: (tripController) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault - 3),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, spreadRadius: 0)
          ],
        ),
        child: Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'trip_id'.tr}: #${trips?.id}',
                      style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    DateConverter.utcToDateTime(trips!.createdAt!),
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor),
                  ),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    PriceConverterHelper.convertPrice(trips!.tripAmount!),
                    style: robotoBold.copyWith(fontWeight: FontWeight.w600),
                  ),
                  tripController.tripsList?[index].tripStatus == 'completed'
                      ? Text(
                          trips!.paymentStatus!.tr.toTitleCase(),
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).colorScheme.error),
                        )
                      : const SizedBox(),
                ]),
              ]),
          InkWell(
            onTap: onToggle,
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).disabledColor,
            ),
          ),
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.av_timer,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((0.7 * 255).round()),
                            size: 20),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        RichText(
                          text: TextSpan(
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor),
                            children: [
                              TextSpan(
                                  text: trips!.tripType!.tr.toTitleCase(),
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withAlpha((0.7 * 255).round()))),
                              const TextSpan(
                                text: ' ',
                              ),
                              TextSpan(
                                  text:
                                      '(${trips?.scheduled == 1 ? 'scheduled'.tr : 'instant'.tr})',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor)),
                            ],
                          ),
                        ),
                      ]),
                      RichText(
                        text: TextSpan(
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                          children: [
                            TextSpan(
                                text: 'estimated'.tr,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor,
                                    fontSize: Dimensions.fontSizeSmall)),
                            const TextSpan(
                              text: ' ',
                            ),
                            TextSpan(
                                text: trips!.tripType == 'hourly'
                                    ? '${trips!.estimatedHours} ${'hrs'.tr}'
                                    : '${trips!.distance?.toStringAsFixed(2)} ${'km'.tr}',
                                style: robotoBold.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withAlpha((0.7 * 255).round()))),
                          ],
                        ),
                      ),
                    ]),
                Divider(color: Theme.of(context).cardColor, thickness: 0.5),
                SizedBox(
                  height: 88,
                  child: Row(children: [
                    Column(children: [
                      Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall + 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Transform.rotate(
                          angle: -0.9,
                          child: Icon(Icons.send_rounded,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withAlpha((0.6 * 255).round()),
                              size: 16),
                        ),
                      ),
                      Column(
                        children: List.generate(4, (index) {
                          return Container(
                            margin: EdgeInsets.only(top: index == 0 ? 0 : 5),
                            color: Theme.of(context)
                                .disabledColor
                                .withAlpha((0.5 * 255).round()),
                            height: 3,
                            width: 1,
                          );
                        }),
                      ),
                      Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall + 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(Icons.location_on_sharp,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withAlpha((0.6 * 255).round()),
                            size: 16),
                      ),
                    ]),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              trips?.pickupLocation?.locationName ?? '',
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withAlpha((0.7 * 255).round())),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 30),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'home'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                            ?.withAlpha((0.7 * 255).round())),
                                  ),
                                  Text(
                                    trips?.destinationLocation?.locationName ??
                                        '',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ]),
                          ]),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            fromDriverDetails
                ? CustomButtonWidget(
                    onPressed: () {
                      Get.to(() => TripDetailsScreen(
                          tripId: trips!.id!, tripStatus: trips!.tripStatus));
                    },
                    height: 35,
                    buttonText: 'trip_details'.tr,
                  )
                : trips?.tripStatus == 'pending'
                    ? Row(children: [
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withAlpha((0.5 * 255).round())),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: CustomButtonWidget(
                              onPressed: () {
                                Get.dialog(
                                  ConfirmationDialogWidget(
                                    icon: Images.warning,
                                    description: 'are_you_sure_to_cancel'.tr,
                                    onYesPressed: () {
                                      tripController
                                          .updateTripStatus(
                                              tripId: trips!.id!,
                                              status: 'canceled')
                                          .then((value) {
                                        Navigator.pop(Get.context!);
                                      });
                                    },
                                  ),
                                );
                              },
                              height: 35,
                              buttonText: 'cancel'.tr,
                              textColor: Theme.of(context).colorScheme.error,
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.1 * 255).round()),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: CustomButtonWidget(
                            isLoading: tripController.isStatusLoading,
                            onPressed: () {
                              tripController.updateTripStatus(
                                  tripId: trips!.id!, status: 'confirmed');
                            },
                            height: 35,
                            buttonText: 'confirm'.tr,
                          ),
                        ),
                      ])
                    : const SizedBox(),
          ],
        ]),
      );
    });
  }
}
