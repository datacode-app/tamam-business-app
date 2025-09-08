// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/text_field_widget.dart';
import 'package:tamam_business/features/order/controllers/order_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class AmountInputDialogueWidget extends StatefulWidget {
  final int orderId;
  final bool isItemPrice;
  final double? amount;
  final double? additionalCharge;
  const AmountInputDialogueWidget({super.key, required this.orderId, required this.isItemPrice, required this.amount, this.additionalCharge});

  @override
  State<AmountInputDialogueWidget> createState() => _AmountInputDialogueWidgetState();
}

class _AmountInputDialogueWidgetState extends State<AmountInputDialogueWidget> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _amountController.text = widget.amount.toString();
    
    // Request focus after the dialog is built to ensure keyboard shows in release mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use a slight delay to ensure dialog animation is complete
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _amountNode.requestFocus();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _amountNode.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          width: 500, 
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              widget.isItemPrice ? 'update_order_amount'.tr : 'update_discount_amount'.tr, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          TextFieldWidget(
            hintText: widget.isItemPrice ? 'order_amount'.tr : 'discount_amount'.tr,
            controller: _amountController,
            focusNode: _amountNode,
            inputAction: TextInputAction.done,
            isAmount: true,
            amountIcon: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<OrderController>(
            builder: (orderController) {
              return !orderController.isLoading ? CustomButtonWidget(
                buttonText: 'submit'.tr,
                onPressed: (){
                  double amount = _amountController.text.trim().isNotEmpty ? double.parse(_amountController.text.trim()) : 0;
                  double finalAmount = amount + (widget.additionalCharge ?? 0);
                  orderController.updateOrderAmount(widget.orderId, widget.isItemPrice ? finalAmount.toString() : _amountController.text.trim(), widget.isItemPrice);
                },
              ) : const CircularProgressIndicator();
            }
          )

              ]),
            ),
          ),
        ),
      ),
    );
  }
}
