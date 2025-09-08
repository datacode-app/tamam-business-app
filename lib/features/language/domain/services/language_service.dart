// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:tamam_business/features/language/domain/models/language_model.dart';
import 'package:tamam_business/features/language/domain/repositories/language_repository_interface.dart';
import 'package:tamam_business/features/language/domain/services/language_service_interface.dart';

class LanguageService implements LanguageServiceInterface {
  final LanguageRepositoryInterface languageRepositoryInterface;
  LanguageService({required this.languageRepositoryInterface});

  @override
  bool setLTR(Locale locale) {
    bool isLtr = true;
    if(locale.languageCode == 'ar' || locale.languageCode == 'ku') {
      return false; // RTL for Arabic and Kurdish Sorani
    } else {
      isLtr = true; // LTR for others
    }
    return isLtr;
  }

  @override
  void updateHeader(Locale locale) {
    languageRepositoryInterface.updateHeader(locale);
  }

  @override
  Locale getLocaleFromSharedPref() {
    return languageRepositoryInterface.getLocaleFromSharedPref();
  }

  @override
  int setSelectedLanguageIndex(List<LanguageModel> languages, Locale locale) {
    int selectedLanguageIndex = 0;
    for(int index = 0; index<languages.length; index++) {
      if(languages[index].languageCode == locale.languageCode) {
        selectedLanguageIndex = index;
        break;
      }
    }
    return selectedLanguageIndex;
  }

  @override
  void saveLanguage(Locale locale) async {
    languageRepositoryInterface.saveLanguage(locale);
  }

  @override
  void saveCacheLanguage(Locale locale) {
    languageRepositoryInterface.saveCacheLanguage(locale);
  }

  @override
  Locale getCacheLocaleFromSharedPref() {
    return languageRepositoryInterface.getCacheLocaleFromSharedPref();
  }

}
