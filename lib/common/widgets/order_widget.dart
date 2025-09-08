// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/confirmation_dialog_widget.dart';
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/features/order/controllers/order_controller.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/features/order/screens/order_details_screen.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool hasDivider;
  final bool isRunning;
  final bool showStatus;
  const OrderWidget({
    super.key,
    required this.orderModel,
    required this.hasDivider,
    required this.isRunning,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => Get.toNamed(
            RouteHelper.getOrderDetailsRoute(orderModel.id ?? 0),
            arguments: OrderDetailsScreen(
              orderId: orderModel.id ?? 0,
              isRunningOrder: isRunning,
            ),
          ),
      child: Column(
        children: [
          Row(
            children: [
              DateBox(time: orderModel.createdAt!, isRunning: isRunning),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${'order'.tr} #', style: robotoRegular),
                        Text(
                          '${orderModel.id}',
                          style: robotoMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        _buildStatusIndicator(),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      width: context.width - 100,
                      child: Text(
                        orderModel.customer != null
                            ? '${orderModel.customer!.fName} ${orderModel.customer!.lName}'
                            : 'walking_customer'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // FLEET MANAGEMENT - TEMPORARILY DISABLED FOR STABLE RELEASE
              // Assignment icon was here for confirmed orders with self-delivery
              // TODO: Re-enable after completing database migrations and proper testing
              /*
          if (_shouldShowAssignmentButton())
            GetBuilder<OrderController>(
              builder: (orderController) {
                return IconButton(
                  icon: const Icon(Icons.person_add_alt_1),
                  onPressed: () => _handleDeliveryAssignment(orderController),
                  tooltip: 'assign_delivery_man'.tr,
                );
              }
            ),
          */
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height:
                (orderModel.orderStatus == 'pending' &&
                        orderModel.orderType == 'take_away')
                    ? 55
                    : (orderModel.orderStatus == 'pending' ||
                        orderModel.orderStatus == 'processing' ||
                        orderModel.orderStatus == 'accepted')
                    ? Get.find<ProfileController>()
                                .profileModel!
                                .stores![0]
                                .selfDeliverySystem ==
                            1
                        ? 100
                        : 55
                    : (orderModel.orderStatus == 'confirmed')
                    ? 0
                    : 0,
            child:
                (orderModel.orderStatus == 'pending' &&
                        orderModel.orderType == 'take_away')
                    ? Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                () => Get.dialog(
                                  ConfirmationDialogWidget(
                                    icon: Images.warning,
                                    title: 'are_you_sure_to_reject'.tr,
                                    description:
                                        'you_want_to_reject_this_order'.tr,
                                    onYesPressed: () {
                                      Get.find<OrderController>()
                                          .updateOrderStatus(
                                            orderModel.id,
                                            'canceled',
                                            back: true,
                                          )
                                          .then((success) {
                                            if (success) {
                                              Get.find<OrderController>()
                                                  .getCurrentOrders();
                                            }
                                          });
                                    },
                                  ),
                                  barrierDismissible: false,
                                ),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(1170, 40),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                side: BorderSide(
                                  width: 1,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                ),
                              ),
                            ),
                            child: Text(
                              'reject'.tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: CustomButtonWidget(
                            height: 40,
                            buttonText: 'confirm'.tr,
                            onPressed: () {
                              Get.find<OrderController>()
                                  .updateOrderStatus(
                                    orderModel.id,
                                    'confirmed',
                                    back: true,
                                  )
                                  .then((success) {
                                    if (success) {
                                      Get.find<OrderController>()
                                          .getCurrentOrders();
                                    }
                                  });
                            },
                          ),
                        ),
                      ],
                    )
                    : (orderModel.orderStatus == 'pending' ||
                        orderModel.orderStatus == 'processing' ||
                        orderModel.orderStatus == 'accepted')
                    ? GetBuilder<OrderController>(
                      builder: (orderController) {
                        return (Get.find<ProfileController>()
                                        .profileModel!
                                        .stores![0]
                                        .selfDeliverySystem ==
                                    1 &&
                                orderModel.deliveryMan == null &&
                                orderModel.orderType != 'take_away')
                            ? Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed:
                                              () => Get.dialog(
                                                ConfirmationDialogWidget(
                                                  icon: Images.warning,
                                                  title:
                                                      'are_you_sure_to_reject'
                                                          .tr,
                                                  description:
                                                      'you_want_to_reject_this_order'
                                                          .tr,
                                                  onYesPressed: () {
                                                    orderController
                                                        .updateOrderStatus(
                                                          orderModel.id,
                                                          'canceled',
                                                          back: true,
                                                        )
                                                        .then((success) {
                                                          if (success) {
                                                            Get.find<
                                                                  OrderController
                                                                >()
                                                                .getCurrentOrders();
                                                          }
                                                        });
                                                  },
                                                ),
                                                barrierDismissible: false,
                                              ),
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(1170, 40),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusSmall,
                                                  ),
                                              side: BorderSide(
                                                width: 1,
                                                color:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color!,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'reject'.tr,
                                            textAlign: TextAlign.center,
                                            style: robotoRegular.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color,
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),
                                      Expanded(
                                        child: CustomButtonWidget(
                                          height: 40,
                                          buttonText: 'confirm'.tr,
                                          onPressed: () {
                                            orderController
                                                .updateOrderStatus(
                                                  orderModel.id,
                                                  'confirmed',
                                                  back: true,
                                                )
                                                .then((success) {
                                                  if (success) {
                                                    Get.find<OrderController>()
                                                        .getCurrentOrders();
                                                  }
                                                });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            // FLEET MANAGEMENT - TEMPORARILY DISABLED FOR STABLE RELEASE
                            // Additional assign button was here for self-delivery orders
                            // TODO: Re-enable after completing database migrations and proper testing
                            /*
                            : Column(children: [
                              Expanded(
                                child: Row(children: [
                                  Expanded(
                                      child: TextButton(
                                    onPressed: () => Get.dialog(
                                        ConfirmationDialogWidget(
                                          icon: Images.warning,
                                          title: 'are_you_sure_to_reject'.tr,
                                          description:
                                              'you_want_to_reject_this_order'
                                                  .tr,
                                          onYesPressed: () {
                                            orderController
                                                .updateOrderStatus(
                                                    orderModel.id, 'canceled',
                                                    back: true)
                                                .then((success) {
                                              if (success) {
                                                Get.find<OrderController>()
                                                    .getCurrentOrders();
                                              }
                                            });
                                          },
                                        ),
                                        barrierDismissible: false),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(1170, 40),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall),
                                        side: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!),
                                      ),
                                    ),
                                    child: Text('reject'.tr,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                          fontSize: Dimensions.fontSizeLarge,
                                        )),
                                  )),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                      child: CustomButtonWidget(
                                    height: 40,
                                    buttonText: 'confirm'.tr,
                                    onPressed: () {
                                      orderController
                                          .updateOrderStatus(
                                              orderModel.id, 'confirmed',
                                              back: true)
                                          .then((success) {
                                        if (success) {
                                          Get.find<OrderController>()
                                              .getCurrentOrders();
                                        }
                                      });
                                    },
                                  )),
                                ]),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              CustomButtonWidget(
                                height: 40,
                                buttonText: 'assign_self_delivery_man'.tr,
                                onPressed: () {
                                  // orderController
                                  //     .getDeliveryManList(orderModel);
                                  // Get.toNamed(
                                  //     RouteHelper.getSelectDeliveryManRoute(
                                  //         orderModel.id));
                                },
                              ),
                            ])
                            */
                            : Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed:
                                        () => Get.dialog(
                                          ConfirmationDialogWidget(
                                            icon: Images.warning,
                                            title: 'are_you_sure_to_reject'.tr,
                                            description:
                                                'you_want_to_reject_this_order'
                                                    .tr,
                                            onYesPressed: () {
                                              orderController
                                                  .updateOrderStatus(
                                                    orderModel.id,
                                                    'canceled',
                                                    back: true,
                                                  )
                                                  .then((success) {
                                                    if (success) {
                                                      Get.find<
                                                            OrderController
                                                          >()
                                                          .getCurrentOrders();
                                                    }
                                                  });
                                            },
                                          ),
                                          barrierDismissible: false,
                                        ),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(1170, 50),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color!,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'reject'.tr,
                                      textAlign: TextAlign.center,
                                      style: robotoRegular.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.color,
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                                Expanded(
                                  child: CustomButtonWidget(
                                    buttonText: 'confirm'.tr,
                                    onPressed: () {
                                      orderController
                                          .updateOrderStatus(
                                            orderModel.id,
                                            'confirmed',
                                            back: true,
                                          )
                                          .then((success) {
                                            if (success) {
                                              Get.find<OrderController>()
                                                  .getCurrentOrders();
                                            }
                                          });
                                    },
                                  ),
                                ),
                              ],
                            );
                      },
                    )
                    : const SizedBox.shrink(),
          ),
          hasDivider
              ? Divider(color: Theme.of(context).disabledColor)
              : const SizedBox(),
        ],
      ),
    );
  }

  // FLEET MANAGEMENT HELPER METHODS - TEMPORARILY DISABLED FOR STABLE RELEASE
  // TODO: Re-enable after completing database migrations and proper testing
  /*
  bool _shouldShowAssignmentButton() {
    return Get.find<ProfileController>()
                .profileModel!
                .stores![0]
                .selfDeliverySystem ==
            1 &&
        orderModel.deliveryMan == null &&
        orderModel.orderType != 'take_away';
  }

  void _handleDeliveryAssignment(OrderController orderController) {
    // orderController.getDeliveryManList(orderModel);
    // Get.toNamed(RouteHelper.getSelectDeliveryManRoute(orderModel.id));
  }

  Widget _buildConfirmedOrderActions() {
    return GetBuilder<OrderController>(builder: (orderController) {
      // For confirmed orders, show different actions based on delivery assignment
      if (_shouldShowAssignmentButton()) {
        // The assignment button is now an icon in the main row.
        return const SizedBox(height: 50);
      } else {
        // Order is confirmed and has delivery assignment or is take-away
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Colors.green.withAlpha((0.3 * 255).round())),
          ),
          child: Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Text(
                orderModel.deliveryMan != null
                    ? 'assigned_to_delivery_man'.tr
                    : orderModel.orderType == 'take_away'
                        ? 'ready_for_pickup'.tr
                        : 'order_confirmed'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ]),
        );
      }
    });
  }
  */

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (orderModel.orderStatus) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'pending'.tr;
        statusIcon = Icons.schedule;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'confirmed'.tr;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'processing':
        statusColor = Colors.purple;
        statusText = 'processing'.tr;
        statusIcon = Icons.restaurant;
        break;
      case 'ready_for_handover':
        statusColor = Colors.green;
        statusText = 'handover'.tr;
        statusIcon = Icons.done_all;
        break;
      case 'picked_up':
        statusColor = Colors.indigo;
        statusText = 'food_on_the_way'.tr;
        statusIcon = Icons.delivery_dining;
        break;
      case 'delivered':
        statusColor = Colors.green.shade700;
        statusText = 'delivered'.tr;
        statusIcon = Icons.check_circle;
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusText = 'canceled'.tr;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = orderModel.orderStatus?.tr ?? '';
        statusIcon = Icons.help_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, size: 16, color: statusColor),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            decoration: BoxDecoration(
              color: statusColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: statusColor.withAlpha((0.3 * 255).round())),
            ),
            child: Text(
              statusText,
              style: robotoMedium.copyWith(
                color: statusColor,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Show delivery assignment status for confirmed orders
        // if (orderModel.orderStatus == 'confirmed' && _shouldShowAssignmentButton()) ...[
        //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        //   Icon(
        //     Icons.assignment_ind,
        //     size: 14,
        //     color: Colors.orange,
        //   ),
        // ],
      ],
    );
  }

  // FLEET MANAGEMENT METHOD - TEMPORARILY DISABLED FOR STABLE RELEASE
  // TODO: Re-enable after completing database migrations and proper testing

  // void _handleDeliveryAssignment(OrderController orderController) {
  //   // Check if there are available delivery men
  //   orderController.getAvailableDrivers(orderModel.id!).then((_) {
  //     if (orderController.availableDrivers != null &&
  //         orderController.availableDrivers!.isNotEmpty) {
  //       // Navigate to delivery man selection screen
  //       Get.toNamed(
  //         RouteHelper.getSelectDeliveryManRoute(orderModel.id!),
  //       );
  //     } else {
  //       // Try auto-assignment or show no drivers message
  //       Get.dialog(
  //         ConfirmationDialogWidget(
  //           icon: Images.warning,
  //           title: 'no_delivery_men_available'.tr,
  //           description: 'would_you_like_to_try_auto_assignment'.tr,
  //           onYesPressed: () {
  //             Get.back();
  //             orderController.autoAssignBestDriver(orderModel.id!);
  //           },
  //           onNoPressed: () => Get.back(),
  //         ),
  //       );
  //     }
  //   });
  // }
}

class DateBox extends StatelessWidget {
  final String time;
  final bool isRunning;
  const DateBox({super.key, required this.time, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: isRunning ? Theme.of(context).primaryColor : Colors.green,
      ),
      child: Center(
        child: Text(
          DateConverter.isoToDate(time),
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}
