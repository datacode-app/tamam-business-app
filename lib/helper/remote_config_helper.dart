import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:tamam_business/helper/remote_config_override.dart';

class RemoteConfigHelper {
  static FirebaseRemoteConfig? _remoteConfig;
  static bool _initialized = false;

  // Default values that match your Firebase Remote Config
  // ALL MONETIZATION FLAGS DEFAULT TO FALSE FOR APPLE APP STORE COMPLIANCE
  static const Map<String, dynamic> _defaults = {
    // Basic config
    'backend_base_url': 'https://admin.tamam.shop',
    'backend_base_url_2': 'https://dev1.tamam.krd',
    'backend_base_url_dev': 'https://dev1.tamam.krd',
    'is_under_review': false,
    'review_latitude': '36.20189664084562',
    'review_longitude': '43.97175107387818',
    'reviewZoneBypassEnabled': false,
    'enableVendorRegistration': false, // Default to false for Apple App Store compliance

    // === BUSINESS PLAN MANAGEMENT FLAGS (Apple rejection fix) ===
    'enableBusinessPlanView': false, // Show/hide current business plan display
    'enableBusinessPlanChanges': false, // Allow changing business plans
    'enablePlanUpgradeOptions': false, // Show upgrade/downgrade buttons

    // === SUBSCRIPTION FEATURES ===
    'enableSubscriptionManagement': false, // Access to subscription management screens
    'enableSubscriptionPayments': false, // Allow subscription payment processing
    'enableSubscriptionUpgrades': false, // Show subscription upgrade options
    'enableSubscriptionDowngrades': false, // Allow subscription downgrades

    // === COMMISSION FEATURES ===
    'enableCommissionView': false, // Show current commission rates
    'enableCommissionChanges': false, // Allow commission rate modifications
    'enableCommissionManagement': false, // Access to commission management screens

    // === PLAN SELECTION FEATURES ===
    'enablePlanSelectionRegistration': false, // Business plan selection during registration
    'enablePlanComparison': false, // Show plan comparison screens
    'enablePricingDisplays': false, // Show pricing information for plans

    // === PAYMENT & BILLING FEATURES ===
    'enablePaymentProcessing': false, // In-app payment processing for business plans
    'enableBillingHistory': false, // Show billing/payment history
    'enableInvoiceManagement': false, // Access to invoice features

    // === NAVIGATION & UI FEATURES ===
    'enable_monetization_menus': false, // Show menu items for monetization features
    'enable_upgrade_prompts': false, // Show upgrade notifications/prompts
    'enable_plan_widgets': false, // Show business plan widgets/cards

    // === ADVANCED MONETIZATION FLAGS ===
    'enable_trial_management': false, // Trial period management
    'enable_auto_renewal': false, // Automatic subscription renewal
    'enable_subscription_cancellation': false, // Allow canceling subscriptions
    'enable_refund_requests': false, // Allow requesting refunds
    'enable_plan_recommendations': false, // Show recommended plan suggestions
  };

  /// Initialize Remote Config
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig!.setDefaults(_defaults);

      // Configure settings
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode
                  ? const Duration(seconds: 10) // Debug: fetch frequently
                  : const Duration(hours: 1), // Production: fetch hourly
        ),
      );

      // Initial fetch
      await fetchAndActivate();
      _initialized = true;

      if (kDebugMode) {
        debugPrint('🔥 Remote Config initialized successfully');
        debugPrint('🍎 App Store Review Mode: ${isUnderReview()}');
        debugPrint('🌐 Backend Base URL: ${getBackendBaseUrl()}');
        debugPrint('🏪 Vendor Registration Enabled: ${isVendorRegistrationEnabled()}');
        debugPrint('💰 Monetization Status: ${getMonetizationStatus()}');
        if (!isAnyMonetizationFeatureEnabled()) {
          debugPrint('⚠️  ALL MONETIZATION FEATURES DISABLED FOR APPLE COMPLIANCE');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Remote Config initialization failed: $e');
      }
      _initialized = false;
    }
  }

  /// Fetch and activate new config values
  static Future<bool> fetchAndActivate() async {
    if (_remoteConfig == null) return false;

    try {
      bool updated = await _remoteConfig!.fetchAndActivate();
      if (kDebugMode && updated) {
        debugPrint('🔄 Remote Config updated with new values');
      }
      return updated;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Remote Config fetch failed: $e');
      }
      return false;
    }
  }

  /// Get backend base URL from Remote Config
  static String getBackendBaseUrl() {
    // In debug builds, force staging URL to simplify debugging
    if (kDebugMode) {
      return 'https://admin-stag.tamam.krd';
    }
    return _remoteConfig?.getString('backend_base_url') ??
        _defaults['backend_base_url'];
  }

  /// Get backup backend base URL from Remote Config
  static String getBackendBaseUrl2() {
    return _remoteConfig?.getString('backend_base_url_2') ??
        _defaults['backend_base_url_2'];
  }

  /// Get development backend base URL from Remote Config
  static String getBackendBaseUrlDev() {
    return _remoteConfig?.getString('backend_base_url_dev') ??
        _defaults['backend_base_url_dev'];
  }

  /// Check if app is under App Store review
  static bool isUnderReview() {
    return _remoteConfig?.getBool('is_under_review') ??
        _defaults['is_under_review'];
  }

  /// Get review mode latitude
  static String getReviewLatitude() {
    return _remoteConfig?.getString('review_latitude') ??
        _defaults['review_latitude'];
  }

  /// Get review mode longitude
  static String getReviewLongitude() {
    return _remoteConfig?.getString('review_longitude') ??
        _defaults['review_longitude'];
  }

  /// Check if zone bypass is enabled for review
  static bool isReviewZoneBypassEnabled() {
    return _remoteConfig?.getBool('review_zone_bypass_enabled') ??
        _defaults['review_zone_bypass_enabled'];
  }

  /// Check if vendor registration is enabled
  /// Set to false for Apple App Store to comply with guideline 3.1.1
  /// Set to true for Google Play Store and other distributions
  static bool isVendorRegistrationEnabled() {
    return _remoteConfig?.getBool('enableVendorRegistration') ??
        _defaults['enableVendorRegistration'] ?? false;
  }

  // === BUSINESS PLAN MANAGEMENT METHODS (Apple rejection fix) ===

  /// Check if business plan viewing is enabled
  /// This controls display of current business plan information
  /// CRITICAL: For Apple App Store compliance, this MUST default to false
  static bool isBusinessPlanViewEnabled() {
    // 🚨 TEMPORARY: Force disable for Apple compliance testing
    if (kDebugMode) {
      return RemoteConfigOverride.getValue('enableBusinessPlanView', false);
    }
    
    bool enabled = _remoteConfig?.getBool('enableBusinessPlanView') ??
        _defaults['enableBusinessPlanView'] ?? false; // Force false if null
    if (kDebugMode) {
      debugPrint('🏢 Business Plan View Enabled: $enabled');
      debugPrint('🏢 Remote Config Initialized: ${_remoteConfig != null}');
    }
    return enabled;
  }

  /// Check if business plan changes are enabled
  /// This controls "Change Business Plan" buttons and functionality
  /// CRITICAL: For Apple App Store compliance, this MUST default to false
  static bool isBusinessPlanChangesEnabled() {
    // 🚨 TEMPORARY: Force disable for Apple compliance testing
    if (kDebugMode) {
      return RemoteConfigOverride.getValue('enableBusinessPlanChanges', false);
    }
    
    bool enabled = _remoteConfig?.getBool('enableBusinessPlanChanges') ??
        _defaults['enableBusinessPlanChanges'] ?? false; // Force false if null
    if (kDebugMode) {
      debugPrint('🔄 Business Plan Changes Enabled: $enabled');
      debugPrint('🔄 Remote Config Initialized: ${_remoteConfig != null}');
    }
    return enabled;
  }

  /// Check if plan upgrade options are enabled
  /// This controls upgrade/downgrade buttons and recommendations
  static bool isPlanUpgradeOptionsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_plan_upgrade_options') ??
        _defaults['enable_plan_upgrade_options'];
    if (kDebugMode) {
      debugPrint('⬆️ Plan Upgrade Options Enabled: $enabled');
    }
    return enabled;
  }

  // === SUBSCRIPTION FEATURES ===

  /// Check if subscription management is enabled
  /// This controls access to subscription management screens
  static bool isSubscriptionManagementEnabled() {
    // 🚨 TEMPORARY: Force disable for Apple compliance testing
    if (kDebugMode) {
      return RemoteConfigOverride.getValue('enableSubscriptionManagement', false);
    }
    
    bool enabled = _remoteConfig?.getBool('enableSubscriptionManagement') ??
        _defaults['enableSubscriptionManagement'] ?? false;
    if (kDebugMode) {
      debugPrint('🔒 Subscription Management Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if subscription payments are enabled
  /// This controls in-app payment processing for subscriptions
  static bool isSubscriptionPaymentsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_subscription_payments') ??
        _defaults['enable_subscription_payments'];
    if (kDebugMode) {
      debugPrint('💳 Subscription Payments Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if subscription upgrades are enabled
  static bool isSubscriptionUpgradesEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_subscription_upgrades') ??
        _defaults['enable_subscription_upgrades'];
    if (kDebugMode) {
      debugPrint('📈 Subscription Upgrades Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if subscription downgrades are enabled
  static bool isSubscriptionDowngradesEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_subscription_downgrades') ??
        _defaults['enable_subscription_downgrades'];
    if (kDebugMode) {
      debugPrint('📉 Subscription Downgrades Enabled: $enabled');
    }
    return enabled;
  }

  // === COMMISSION FEATURES ===

  /// Check if commission view is enabled
  static bool isCommissionViewEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_commission_view') ??
        _defaults['enable_commission_view'];
    if (kDebugMode) {
      debugPrint('📊 Commission View Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if commission changes are enabled
  static bool isCommissionChangesEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_commission_changes') ??
        _defaults['enable_commission_changes'];
    if (kDebugMode) {
      debugPrint('📝 Commission Changes Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if commission management is enabled
  static bool isCommissionManagementEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_commission_management') ??
        _defaults['enable_commission_management'];
    if (kDebugMode) {
      debugPrint('⚙️ Commission Management Enabled: $enabled');
    }
    return enabled;
  }

  // === PLAN SELECTION FEATURES ===

  /// Check if plan selection during registration is enabled
  static bool isPlanSelectionRegistrationEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_plan_selection_registration') ??
        _defaults['enable_plan_selection_registration'];
    if (kDebugMode) {
      debugPrint('📝 Plan Selection Registration Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if plan comparison is enabled
  static bool isPlanComparisonEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_plan_comparison') ??
        _defaults['enable_plan_comparison'];
    if (kDebugMode) {
      debugPrint('⚖️ Plan Comparison Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if pricing displays are enabled
  static bool isPricingDisplaysEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_pricing_displays') ??
        _defaults['enable_pricing_displays'];
    if (kDebugMode) {
      debugPrint('💰 Pricing Displays Enabled: $enabled');
    }
    return enabled;
  }

  // === PAYMENT & BILLING FEATURES ===

  /// Check if payment processing is enabled
  static bool isPaymentProcessingEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_payment_processing') ??
        _defaults['enable_payment_processing'];
    if (kDebugMode) {
      debugPrint('💳 Payment Processing Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if billing history is enabled
  static bool isBillingHistoryEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_billing_history') ??
        _defaults['enable_billing_history'];
    if (kDebugMode) {
      debugPrint('📄 Billing History Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if invoice management is enabled
  static bool isInvoiceManagementEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_invoice_management') ??
        _defaults['enable_invoice_management'];
    if (kDebugMode) {
      debugPrint('🧾 Invoice Management Enabled: $enabled');
    }
    return enabled;
  }

  // === NAVIGATION & UI FEATURES ===

  /// Check if monetization menus are enabled
  static bool isMonetizationMenusEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_monetization_menus') ??
        _defaults['enable_monetization_menus'];
    if (kDebugMode) {
      debugPrint('📋 Monetization Menus Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if upgrade prompts are enabled
  static bool isUpgradePromptsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_upgrade_prompts') ??
        _defaults['enable_upgrade_prompts'];
    if (kDebugMode) {
      debugPrint('🔔 Upgrade Prompts Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if plan widgets are enabled
  static bool isPlanWidgetsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_plan_widgets') ??
        _defaults['enable_plan_widgets'];
    if (kDebugMode) {
      debugPrint('🎨 Plan Widgets Enabled: $enabled');
    }
    return enabled;
  }

  // === ADVANCED MONETIZATION FLAGS ===

  /// Check if trial management is enabled
  static bool isTrialManagementEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_trial_management') ??
        _defaults['enable_trial_management'];
    if (kDebugMode) {
      debugPrint('⏱️ Trial Management Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if auto renewal is enabled
  static bool isAutoRenewalEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_auto_renewal') ??
        _defaults['enable_auto_renewal'];
    if (kDebugMode) {
      debugPrint('🔄 Auto Renewal Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if subscription cancellation is enabled
  static bool isSubscriptionCancellationEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_subscription_cancellation') ??
        _defaults['enable_subscription_cancellation'];
    if (kDebugMode) {
      debugPrint('❌ Subscription Cancellation Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if refund requests are enabled
  static bool isRefundRequestsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_refund_requests') ??
        _defaults['enable_refund_requests'];
    if (kDebugMode) {
      debugPrint('💸 Refund Requests Enabled: $enabled');
    }
    return enabled;
  }

  /// Check if plan recommendations are enabled
  static bool isPlanRecommendationsEnabled() {
    bool enabled = _remoteConfig?.getBool('enable_plan_recommendations') ??
        _defaults['enable_plan_recommendations'];
    if (kDebugMode) {
      debugPrint('🎯 Plan Recommendations Enabled: $enabled');
    }
    return enabled;
  }

  // === COMBINATION HELPER METHODS ===

  /// Check if any business plan features are enabled
  /// Useful for showing/hiding entire business plan sections
  static bool isAnyBusinessPlanFeatureEnabled() {
    return isBusinessPlanViewEnabled() || 
           isBusinessPlanChangesEnabled() || 
           isPlanUpgradeOptionsEnabled();
  }

  /// Check if any subscription features are enabled
  /// Useful for showing/hiding entire subscription sections
  static bool isAnySubscriptionFeatureEnabled() {
    return isSubscriptionManagementEnabled() || 
           isSubscriptionPaymentsEnabled() || 
           isSubscriptionUpgradesEnabled() || 
           isSubscriptionDowngradesEnabled();
  }

  /// Check if any monetization feature is enabled
  /// Master flag to check if any monetization is active
  static bool isAnyMonetizationFeatureEnabled() {
    return isAnyBusinessPlanFeatureEnabled() || 
           isAnySubscriptionFeatureEnabled() || 
           isCommissionViewEnabled() || 
           isPlanSelectionRegistrationEnabled() || 
           isPaymentProcessingEnabled() || 
           isMonetizationMenusEnabled();
  }

  /// Get comprehensive monetization status for debugging
  static Map<String, bool> getMonetizationStatus() {
    return {
      'business_plan_view': isBusinessPlanViewEnabled(),
      'business_plan_changes': isBusinessPlanChangesEnabled(),
      'plan_upgrade_options': isPlanUpgradeOptionsEnabled(),
      'subscription_management': isSubscriptionManagementEnabled(),
      'subscription_payments': isSubscriptionPaymentsEnabled(),
      'subscription_upgrades': isSubscriptionUpgradesEnabled(),
      'subscription_downgrades': isSubscriptionDowngradesEnabled(),
      'commission_view': isCommissionViewEnabled(),
      'commission_changes': isCommissionChangesEnabled(),
      'commission_management': isCommissionManagementEnabled(),
      'plan_selection_registration': isPlanSelectionRegistrationEnabled(),
      'plan_comparison': isPlanComparisonEnabled(),
      'pricing_displays': isPricingDisplaysEnabled(),
      'payment_processing': isPaymentProcessingEnabled(),
      'billing_history': isBillingHistoryEnabled(),
      'invoice_management': isInvoiceManagementEnabled(),
      'monetization_menus': isMonetizationMenusEnabled(),
      'upgrade_prompts': isUpgradePromptsEnabled(),
      'plan_widgets': isPlanWidgetsEnabled(),
      'trial_management': isTrialManagementEnabled(),
      'auto_renewal': isAutoRenewalEnabled(),
      'subscription_cancellation': isSubscriptionCancellationEnabled(),
      'refund_requests': isRefundRequestsEnabled(),
      'plan_recommendations': isPlanRecommendationsEnabled(),
      'any_business_plan_enabled': isAnyBusinessPlanFeatureEnabled(),
      'any_subscription_enabled': isAnySubscriptionFeatureEnabled(),
      'any_monetization_enabled': isAnyMonetizationFeatureEnabled(),
    };
  }

  /// Get all current Remote Config values (for debugging)
  static Map<String, dynamic> getAllValues() {
    if (_remoteConfig == null) return _defaults;

    Map<String, dynamic> allValues = {
      // Basic config
      'backend_base_url': getBackendBaseUrl(),
      'backend_base_url_2': getBackendBaseUrl2(),
      'backend_base_url_dev': getBackendBaseUrlDev(),
      'is_under_review': isUnderReview(),
      'review_latitude': getReviewLatitude(),
      'review_longitude': getReviewLongitude(),
      'review_zone_bypass_enabled': isReviewZoneBypassEnabled(),
      'enable_vendor_registration': isVendorRegistrationEnabled(),
    };

    // Add all monetization flags
    allValues.addAll(getMonetizationStatus());
    
    return allValues;
  }

  /// Force refresh config (useful for testing)
  static Future<bool> forceRefresh() async {
    if (_remoteConfig == null) return false;

    try {
      // Set minimum fetch interval to 0 for immediate fetch
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      bool updated = await _remoteConfig!.fetchAndActivate();

      // Reset to normal fetch interval
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode
                  ? const Duration(seconds: 10)
                  : const Duration(hours: 1),
        ),
      );

      if (kDebugMode) {
        debugPrint('🔄 Force refresh completed. Updated: $updated');
        debugPrint('📊 Current values: ${getAllValues()}');
      }

      return updated;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Force refresh failed: $e');
      }
      return false;
    }
  }
}
