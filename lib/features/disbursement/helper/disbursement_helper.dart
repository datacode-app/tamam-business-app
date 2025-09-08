// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/disbursement/controllers/disbursement_controller.dart';
import 'package:tamam_business/features/disbursement/widgets/withdraw_method_attention_dialog_widget.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/util/dimensions.dart';

class DisbursementHelper {

  Future<bool> enableDisbursementWarningMessage(bool fromDashboard, {bool canShowDialog = true}) async {

    bool showWarning = false;

    if(Get.find<SplashController>().configModel?.disbursementType == 'automated'){
      await Get.find<DisbursementController>().getDisbursementMethodList().then((success) {
        if(success){
          if(Get.find<DisbursementController>().disbursementMethodBody?.methods?.isNotEmpty == true){
            for (var method in Get.find<DisbursementController>().disbursementMethodBody!.methods!) {
              if(method.isDefault == true){
                showWarning = false;
                break;
              } else {
                showWarning = true;
              }
            }
          }else {
            showWarning = true;
          }
        }
      });
    } else {
      showWarning = false;
    }

    if(showWarning && canShowDialog) {
      Get.dialog(
        Dialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: const Color(0xfffff1f1),
          insetPadding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)), //this right here
          child: WithdrawMethodAttentionDialogWidget(isFromDashboard: fromDashboard),
        ),
      );
    }
    return showWarning;
  }

}
