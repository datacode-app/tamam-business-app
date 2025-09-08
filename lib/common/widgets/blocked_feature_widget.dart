// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

/// Widget shown when a monetization feature is disabled via Remote Config
/// Used for Apple App Store compliance - blocks access to monetization features
/// while providing user-friendly messaging and fallback options
class BlockedFeatureWidget extends StatelessWidget {
  final String featureName;
  final String? customTitle;
  final String? customDescription;
  final String? customButtonText;
  final VoidCallback? onContactSupport;
  final VoidCallback? onWebPortal;
  final bool showContactSupport;
  final bool showWebPortal;
  final bool isFullScreen;
  final IconData? customIcon;
  final Color? customIconColor;

  const BlockedFeatureWidget({
    super.key,
    required this.featureName,
    this.customTitle,
    this.customDescription,
    this.customButtonText,
    this.onContactSupport,
    this.onWebPortal,
    this.showContactSupport = true,
    this.showWebPortal = true,
    this.isFullScreen = false,
    this.customIcon,
    this.customIconColor,
  });

  /// Factory for business plan related blocks
  factory BlockedFeatureWidget.businessPlan({
    String? customTitle,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    return BlockedFeatureWidget(
      featureName: 'business_plan',
      customTitle: customTitle ?? 'business_plan_not_available'.tr,
      customDescription: 'business_plan_blocked_description'.tr,
      customIcon: Icons.business_center_outlined,
      customIconColor: Colors.blue,
      onContactSupport: onContactSupport,
      onWebPortal: onWebPortal,
    );
  }

  /// Factory for subscription related blocks
  factory BlockedFeatureWidget.subscription({
    String? customTitle,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    return BlockedFeatureWidget(
      featureName: 'subscription',
      customTitle: customTitle ?? 'subscription_not_available'.tr,
      customDescription: 'subscription_blocked_description'.tr,
      customIcon: Icons.subscriptions_outlined,
      customIconColor: Colors.purple,
      onContactSupport: onContactSupport,
      onWebPortal: onWebPortal,
    );
  }

  /// Factory for payment related blocks
  factory BlockedFeatureWidget.payment({
    String? customTitle,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    return BlockedFeatureWidget(
      featureName: 'payment',
      customTitle: customTitle ?? 'payment_not_available'.tr,
      customDescription: 'payment_blocked_description'.tr,
      customIcon: Icons.payment_outlined,
      customIconColor: Colors.green,
      onContactSupport: onContactSupport,
      onWebPortal: onWebPortal,
    );
  }

  /// Factory for commission related blocks
  factory BlockedFeatureWidget.commission({
    String? customTitle,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    return BlockedFeatureWidget(
      featureName: 'commission',
      customTitle: customTitle ?? 'commission_not_available'.tr,
      customDescription: 'commission_blocked_description'.tr,
      customIcon: Icons.percent_outlined,
      customIconColor: Colors.orange,
      onContactSupport: onContactSupport,
      onWebPortal: onWebPortal,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text(customTitle ?? 'feature_not_available'.tr),
          centerTitle: true,
        ),
        body: _buildContent(context),
      );
    }

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isFullScreen ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: isFullScreen ? 100 : 80,
            height: isFullScreen ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (customIconColor ?? Theme.of(context).primaryColor).withAlpha((0.1 * 255).round()),
            ),
            child: Icon(
              customIcon ?? Icons.block_outlined,
              size: isFullScreen ? 50 : 40,
              color: customIconColor ?? Theme.of(context).primaryColor,
            ),
          ),

          SizedBox(height: isFullScreen ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge),

          // Title
          Text(
            customTitle ?? 'feature_temporarily_unavailable'.tr,
            style: robotoBold.copyWith(
              fontSize: isFullScreen ? Dimensions.fontSizeExtraLarge : Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isFullScreen ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isFullScreen ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault,
            ),
            child: Text(
              customDescription ?? _getDefaultDescription(),
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).round()),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: isFullScreen ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge),

          // Action buttons
          if (showContactSupport || showWebPortal) ...[
            if (showContactSupport) ...[
              SizedBox(
                width: double.infinity,
                child: CustomButtonWidget(
                  buttonText: 'contact_support'.tr,
                  onPressed: onContactSupport ?? _defaultContactSupport,
                  radius: Dimensions.radiusDefault,
                  height: 50,
                ),
              ),
              
              if (showWebPortal) const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            if (showWebPortal) ...[
              SizedBox(
                width: double.infinity,
                child: CustomButtonWidget(
                  buttonText: 'use_web_portal'.tr,
                  onPressed: onWebPortal ?? _defaultWebPortal,
                  radius: Dimensions.radiusDefault,
                  height: 50,
                  color: Theme.of(context).cardColor,
                  textColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],

          if (!isFullScreen && showContactSupport) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            
            GestureDetector(
              onTap: () => Get.back(),
              child: Text(
                'go_back'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDefaultDescription() {
    switch (featureName) {
      case 'business_plan':
        return 'business_plan_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr;
      case 'subscription':
        return 'subscription_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr;
      case 'payment':
        return 'payment_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr;
      case 'commission':
        return 'commission_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr;
      default:
        return 'this_feature_is_temporarily_unavailable_please_contact_support_or_use_web_portal'.tr;
    }
  }

  void _defaultContactSupport() {
    // TODO: Implement contact support functionality
    // This could open email, chat, or phone dialer
    Get.snackbar(
      'contact_support'.tr,
      'please_contact_support_via_email_or_phone'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _defaultWebPortal() {
    // TODO: Implement web portal navigation
    // This could open web browser to admin panel
    Get.snackbar(
      'web_portal'.tr,
      'please_use_the_web_portal_to_access_this_feature'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Extension to show blocked feature as bottom sheet
extension BlockedFeatureBottomSheet on BlockedFeatureWidget {
  static void show(
    BuildContext context, {
    required String featureName,
    String? customTitle,
    String? customDescription,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: BlockedFeatureWidget(
          featureName: featureName,
          customTitle: customTitle,
          customDescription: customDescription,
          onContactSupport: onContactSupport,
          onWebPortal: onWebPortal,
        ),
      ),
    );
  }
}

/// Helper class for common blocked feature scenarios
class BlockedFeatureHelper {
  /// Check if feature is enabled and show blocked widget if not
  static bool checkAndBlock(
    BuildContext context, {
    required bool isEnabled,
    required String featureName,
    String? customTitle,
    String? customDescription,
    bool showAsBottomSheet = true,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    if (isEnabled) return true;

    if (showAsBottomSheet) {
      BlockedFeatureBottomSheet.show(
        context,
        featureName: featureName,
        customTitle: customTitle,
        customDescription: customDescription,
        onContactSupport: onContactSupport,
        onWebPortal: onWebPortal,
      );
    }

    return false;
  }

  /// Get blocked feature widget for inline usage
  static Widget getInlineWidget({
    required String featureName,
    String? customTitle,
    String? customDescription,
    VoidCallback? onContactSupport,
    VoidCallback? onWebPortal,
  }) {
    return BlockedFeatureWidget(
      featureName: featureName,
      customTitle: customTitle,
      customDescription: customDescription,
      onContactSupport: onContactSupport,
      onWebPortal: onWebPortal,
    );
  }
}