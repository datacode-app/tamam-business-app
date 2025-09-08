// Flutter imports:
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/util/app_constants.dart';
import 'package:tamam_business/features/language/controllers/language_controller.dart';

ThemeData lightTheme({String languageCode = 'en'}) {
  // Select font based on language parameter
  TextTheme textTheme;
  String fontFamily;

  switch (languageCode) {
    case 'ar':
      // Arabic - Use Vazirmatn font (same as Kurdish)
      textTheme = GoogleFonts.vazirmatnTextTheme();
      fontFamily = GoogleFonts.vazirmatn().fontFamily!;
      break;
    case 'ku':
      // Kurdish Sorani - Use Vazirmatn font
      textTheme = GoogleFonts.vazirmatnTextTheme();
      fontFamily = GoogleFonts.vazirmatn().fontFamily!;
      break;
    default:
      // English and others - Use Roboto (default)
      textTheme = GoogleFonts.robotoTextTheme();
      fontFamily = GoogleFonts.roboto().fontFamily!;
      break;
  }

  return ThemeData(
    fontFamily: fontFamily,
    textTheme: textTheme,
    primaryColor: const Color(0xFFE61A8D),
    secondaryHeaderColor: const Color(0xFF000743),
    disabledColor: const Color(0xFFA0A4A8),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    cardColor: Colors.white,
    shadowColor: Colors.black.withAlpha(8),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFE61A8D)),
    ),
    colorScheme: const ColorScheme.light(
          primary: Color(0xFFE61A8D),
          secondary: Color(0xFFE61A8D),
        )
        .copyWith(error: const Color(0xFFE84D4F))
        .copyWith(surfaceTint: Colors.white),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    ),
    // Modern approach: use colorScheme properties instead of deprecated BottomAppBarThemeData
    dividerTheme: const DividerThemeData(
      thickness: 0.2,
      color: Color(0xFFA0A4A8),
    ),
    tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
  );
}
