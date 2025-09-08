// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final Widget? menuWidget;
  final Function? onTap;
  final Widget? titleWidget;
  const CustomAppBarWidget({super.key, this.title, this.isBackButtonExist = true, this.menuWidget, this.onTap, this.titleWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? Text(title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: onTap as void Function()? ?? () => Get.back(),
      ) : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withAlpha((0.5 * 255).round()),
      elevation: 2,
      actions: menuWidget != null ? [menuWidget!] : null,
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}
