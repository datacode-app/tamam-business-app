// 🚨 TEMPORARY: Force disable all monetization for Apple compliance testing
// Remove this file once Firebase Remote Config is properly configured

class RemoteConfigOverride {
  // Firebase-compliant parameter names (no underscores)
  static const Map<String, bool> _forceDisabled = {
    'enableBusinessPlanChanges': false,
    'enableBusinessPlanView': false,
    'enableSubscriptionManagement': false,
    'enableSubscriptionPayments': false,
    'enableVendorRegistration': false,
    'enableCommissionView': false,
    'enableCommissionChanges': false,
    'enablePlanUpgradeOptions': false,
    'enableMonetizationMenus': false,
    'enablePaymentProcessing': false,
    
    // Legacy support for underscore versions
    'enable_business_plan_changes': false,
    'enable_business_plan_view': false,
    'enable_subscription_management': false,
    'enable_subscription_payments': false,
    'enable_vendor_registration': false,
    'enable_commission_view': false,
    'enable_commission_changes': false,
    'enable_plan_upgrade_options': false,
    'enable_monetization_menus': false,
    'enable_payment_processing': false,
  };
  
  static bool getValue(String key, bool defaultValue) {
    // Force all monetization features to false
    return _forceDisabled[key] ?? false;
  }
}