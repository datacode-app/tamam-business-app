// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';

void showCustomBottomSheet({required Widget child, double? height}) {
  showModalBottomSheet(
    isScrollControlled: true, useRootNavigator: true, context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radiusExtraLarge),
        topRight: Radius.circular(Dimensions.radiusExtraLarge),
      ),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height ?? MediaQuery.of(context).size.height * 0.85),
        child: child,
      );
    },
  );
}
