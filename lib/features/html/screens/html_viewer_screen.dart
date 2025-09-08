// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_app_bar_widget.dart';
import 'package:tamam_business/features/html/controllers/html_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/common/widgets/debug_info_dialog.dart';

class HtmlViewerScreen extends StatefulWidget {
  final bool isPrivacyPolicy;
  const HtmlViewerScreen({super.key, required this.isPrivacyPolicy});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<HtmlController>().getHtmlText(widget.isPrivacyPolicy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: widget.isPrivacyPolicy ? 'privacy_policy'.tr : 'terms_condition'.tr),
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).cardColor,
          child: htmlController.htmlText != null ? SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: widget.isPrivacyPolicy && kDebugMode
                ? GestureDetector(
                    onTap: () => DebugInfoDialog.handleTap(context, 'Privacy Policy - TamamBusiness'),
                    onLongPressStart: (_) => DebugInfoDialog.handleLongPressStart(context, 'Privacy Policy - TamamBusiness'),
                    onLongPressEnd: (_) => DebugInfoDialog.handleLongPressEnd(),
                    child: HtmlWidget(
                      htmlController.htmlText ?? '',
                      key: Key(widget.isPrivacyPolicy ? 'privacy_policy' : 'terms_condition'),
                      onTapUrl: (String url) {
                        return launchUrlString(url, mode: LaunchMode.externalApplication);
                      },
                    ),
                  )
                : HtmlWidget(
                    htmlController.htmlText ?? '',
                    key: Key(widget.isPrivacyPolicy ? 'privacy_policy' : 'terms_condition'),
                    onTapUrl: (String url) {
                      return launchUrlString(url, mode: LaunchMode.externalApplication);
                    },
                  ),
          ) : const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }
}
