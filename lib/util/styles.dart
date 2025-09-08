// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:tamam_business/util/app_constants.dart';
import 'package:tamam_business/features/language/controllers/language_controller.dart';

// Dynamic font family getter
String get _currentFontFamily {
  try {
    final languageCode = Get.find<LocalizationController>().locale.languageCode;
    String fontFamily;
    switch (languageCode) {
      case 'ar':
        fontFamily = GoogleFonts.vazirmatn().fontFamily!;
        break;
      case 'ku':
        fontFamily = GoogleFonts.vazirmatn().fontFamily!;
        break;
      default:
        fontFamily = GoogleFonts.roboto().fontFamily!;
        break;
    }
    return fontFamily;
  } catch (e) {
    return GoogleFonts.roboto().fontFamily!;
  }
}

TextStyle get robotoRegular => TextStyle(
  fontFamily: _currentFontFamily,
  fontWeight: FontWeight.w400,
  color: const Color(0xFFE61A8D),
);

TextStyle get robotoMedium => TextStyle(
  fontFamily: _currentFontFamily,
  fontWeight: FontWeight.w500,
  color: const Color(0xFFE61A8D),
);

TextStyle get robotoBold => TextStyle(
  fontFamily: _currentFontFamily,
  fontWeight: FontWeight.w700,
  color: const Color(0xFFE61A8D),
);

TextStyle get robotoBlack => TextStyle(
  fontFamily: _currentFontFamily,
  fontWeight: FontWeight.w900,
  color: const Color(0xFFE61A8D),
);
