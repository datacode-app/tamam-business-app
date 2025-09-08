import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LocaleHelper {
  static bool _initialized = false;
  
  /// Initialize locale data for proper formatting
  static Future<void> initializeLocales() async {
    if (!_initialized) {
      await initializeDateFormatting();
      _initialized = true;
    }
  }
  
  /// Get a valid locale string for intl package
  /// Handles Kurdish locale fallback to English with custom formatting
  static String getValidLocale() {
    String? localeString = Get.locale?.toString();
    
    if (localeString == null || localeString.isEmpty) {
      return 'en_US';
    }
    
    // Handle Kurdish locale - fallback to English
    if (localeString.startsWith('ku')) {
      return 'en_US';
    }
    
    // Handle other potentially problematic locales
    // Arabic locale should be ar_SA or similar, not just 'ar'
    if (localeString == 'ar') {
      return 'ar_SA';
    }
    
    // For other locales, ensure they have a proper format
    if (!localeString.contains('_') && localeString.length == 2) {
      // Convert 'en' to 'en_US', 'es' to 'es_ES', etc.
      switch (localeString) {
        case 'en':
          return 'en_US';
        case 'es':
          return 'es_ES';
        case 'fr':
          return 'fr_FR';
        case 'de':
          return 'de_DE';
        case 'it':
          return 'it_IT';
        case 'pt':
          return 'pt_BR';
        case 'ru':
          return 'ru_RU';
        case 'ja':
          return 'ja_JP';
        case 'zh':
          return 'zh_CN';
        case 'ko':
          return 'ko_KR';
        default:
          return 'en_US';
      }
    }
    
    return localeString;
  }
  
  /// Format currency with proper locale handling
  static String formatCurrency(double? amount, String symbol, int decimalDigits) {
    if (amount == null) return '$symbol 0';
    
    try {
      String locale = getValidLocale();
      
      // For Kurdish, use custom formatting
      if (Get.locale?.toString().startsWith('ku') ?? false) {
        // Kurdish uses Arabic numerals but with different formatting
        return '$symbol ${amount.toStringAsFixed(decimalDigits)}';
      }
      
      final format = NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits,
      );
      return format.format(amount);
    } catch (e) {
      // Fallback to simple formatting
      return '$symbol ${amount.toStringAsFixed(decimalDigits)}';
    }
  }
  
  /// Format date with proper locale handling
  static String formatDate(DateTime? date, String pattern) {
    if (date == null) return '';
    
    try {
      String locale = getValidLocale();
      
      // For Kurdish, use custom formatting
      if (Get.locale?.toString().startsWith('ku') ?? false) {
        // Use simple formatting for Kurdish
        return _formatDateSimple(date, pattern);
      }
      
      return DateFormat(pattern, locale).format(date);
    } catch (e) {
      // Fallback to simple formatting
      return _formatDateSimple(date, pattern);
    }
  }
  
  /// Parse date with proper locale handling
  static DateTime? parseDate(String? dateString, String pattern) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      String locale = getValidLocale();
      
      // For Kurdish, use custom parsing
      if (Get.locale?.toString().startsWith('ku') ?? false) {
        // Try to parse with simple format
        return DateTime.tryParse(dateString);
      }
      
      return DateFormat(pattern, locale).parse(dateString);
    } catch (e) {
      // Try standard parsing as fallback
      return DateTime.tryParse(dateString);
    }
  }
  
  /// Simple date formatting for unsupported locales
  static String _formatDateSimple(DateTime date, String pattern) {
    // Basic pattern replacements
    String result = pattern;
    
    // Year
    result = result.replaceAll('yyyy', date.year.toString().padLeft(4, '0'));
    result = result.replaceAll('yy', date.year.toString().substring(2).padLeft(2, '0'));
    
    // Month
    result = result.replaceAll('MM', date.month.toString().padLeft(2, '0'));
    result = result.replaceAll('M', date.month.toString());
    
    // Day
    result = result.replaceAll('dd', date.day.toString().padLeft(2, '0'));
    result = result.replaceAll('d', date.day.toString());
    
    // Hour
    result = result.replaceAll('HH', date.hour.toString().padLeft(2, '0'));
    result = result.replaceAll('H', date.hour.toString());
    
    // Minute
    result = result.replaceAll('mm', date.minute.toString().padLeft(2, '0'));
    result = result.replaceAll('m', date.minute.toString());
    
    // Second
    result = result.replaceAll('ss', date.second.toString().padLeft(2, '0'));
    result = result.replaceAll('s', date.second.toString());
    
    return result;
  }
  
  /// Get the current locale code (e.g., 'ku', 'en', 'ar')
  static String getLocaleCode() {
    return Get.locale?.languageCode ?? 'en';
  }
  
  /// Check if current locale is Kurdish
  static bool isKurdish() {
    return Get.locale?.toString().startsWith('ku') ?? false;
  }
}