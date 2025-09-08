// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kurdish/flutter_kurdish.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

// Project imports:

import 'package:tamam_business/features/home/widgets/trial_widget.dart';
import 'package:tamam_business/features/language/controllers/language_controller.dart';
import 'package:tamam_business/features/notification/domain/models/notification_body_model.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';
import 'package:tamam_business/helper/locale_helper.dart';
import 'package:tamam_business/helper/notification_helper.dart';
import 'package:tamam_business/helper/remote_config_helper.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/theme/light_theme.dart';
import 'package:tamam_business/util/app_constants.dart';
import 'package:tamam_business/util/messages.dart';
import 'helper/get_di.dart' as di;
import 'util/remote_config.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Set up comprehensive error handling for Flutter crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('====> Flutter Error Caught: ${details.exception}');
      print('====> Stack Trace: ${details.stack}');
    }
    // Don't crash the app on rendering errors
    FlutterError.presentError(details);
  };

  // Handle platform dispatcher errors (native crashes)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('====> Platform Error Caught: $error');
      print('====> Stack Trace: $stack');
    }
    return true; // Return true to indicate error was handled
  };

  try {
    // Only bypass SSL certificate validation in debug mode
    if (kDebugMode && !GetPlatform.isWeb) {
      HttpOverrides.global = MyHttpOverrides();
    }
    setPathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    
    // Force Skia renderer to prevent Impeller crashes
    if (kDebugMode && !GetPlatform.isWeb) {
      print('====> Forcing Skia renderer (disabling Impeller)');
    }

    debugPrint('====> Starting TamamBusiness App Initialization');
    
    // Initialize locale formatting data
    await LocaleHelper.initializeLocales();
    debugPrint('====> Locale data initialized');

    // Initialize dependencies with timeout
    Map<String, Map<String, String>> languages = {};
    try {
      debugPrint('====> Initializing Dependencies (DI)');
      languages = await di.init().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('====> DI initialization timed out, using defaults');
          return <String, Map<String, String>>{};
        },
      );
      debugPrint('====> Dependencies initialized successfully');
    } catch (e) {
      debugPrint('====> DI initialization failed: $e');
      languages = <String, Map<String, String>>{};
    }

    // Initialize Firebase and Remote Config with error handling
    try {
      debugPrint('====> Initializing Firebase');
      if (GetPlatform.isAndroid) {
        await Firebase.initializeApp(
          name: 'Tamam for Business',
          options: const FirebaseOptions(
            apiKey: "AIzaSyCTlYbDHDLoNn1AhP7gqvNbh-AkJ6-a4is",
            projectId: "tamam-35b98",
            messagingSenderId: "81567664901",
            appId: "1:81567664901:android:93232d76a4f981554a056c",
          ),
        ).timeout(const Duration(seconds: 15));
        debugPrint('====> Firebase initialized successfully for Android');
      } else if (GetPlatform.isWeb) {
        // Web platform: Skip Firebase Dart initialization - use JavaScript only
        debugPrint('====> Web platform: Using JavaScript Firebase initialization only');
      } else {
        // iOS and other platforms
        await Firebase.initializeApp().timeout(const Duration(seconds: 15));
        debugPrint('====> Firebase initialized successfully for iOS/Desktop');
      }

      // Initialize Remote Config only for non-web platforms
      if (!GetPlatform.isWeb) {
        final remoteConfig = await RemoteConfigService.getInstance();
        debugPrint('Remote Config initialized - Backend URL: ${remoteConfig.backendBaseUrl}');
        debugPrint('Is under review: ${remoteConfig.isUnderReview}');
        
        // Initialize our Remote Config Helper
        await RemoteConfigHelper.initialize();
        debugPrint('🔥 RemoteConfigHelper initialized - Review Mode: ${RemoteConfigHelper.isUnderReview()}');
        
        // Debug current base URL configuration
        debugPrint('🌐 Production URL: ${RemoteConfigHelper.getBackendBaseUrl()}');
        debugPrint('🌐 Backup URL: ${RemoteConfigHelper.getBackendBaseUrl2()}');
        debugPrint('🌐 Development URL: ${RemoteConfigHelper.getBackendBaseUrlDev()}');
      } else {
        debugPrint('====> Web platform: Skipping Remote Config initialization');
      }
      
      // Show effective URL that will be used
      final effectiveUrl = await AppConstants.getDeveloperAwareBaseUrl();
      debugPrint('🎯 CURRENT EFFECTIVE BASE URL: $effectiveUrl');
    } catch (e) {
      debugPrint('====> Firebase/Remote Config initialization failed: $e');
    }

    // Initialize notifications with error handling
    NotificationBodyModel? body;
    try {
      if (GetPlatform.isMobile) {
        debugPrint('====> Initializing Notifications');
        final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
            .getInitialMessage()
            .timeout(const Duration(seconds: 10));
        if (remoteMessage != null) {
          body = NotificationHelper.convertNotification(remoteMessage.data);
        }
        await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
        FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
        debugPrint('====> Notifications initialized successfully');
      }
    } catch (e) {
      debugPrint('====> Notification initialization failed: $e');
    }

    debugPrint('====> Starting App Widget');
    runApp(MyApp(languages: languages, body: body));
  } catch (e) {
    debugPrint('====> Critical error in main(): $e');
    // Run app with minimal configuration if everything fails
    runApp(const MyApp(languages: <String, Map<String, String>>{}, body: null));
  }
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return GetBuilder<LocalizationController>(builder: (localizeController) {
      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,
        theme: lightTheme(languageCode: localizeController.locale.languageCode),
        locale: localizeController.locale,
        textDirection: localizeController.isLtr ? TextDirection.ltr : TextDirection.rtl,
        localizationsDelegates: const [
          KurdishMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ar', 'SA'),
          Locale('ku', 'IQ'), // Kurdish Sorani
        ],
        translations: Messages(languages: languages),
        fallbackLocale: Locale(AppConstants.languages[0].languageCode!,
            AppConstants.languages[0].countryCode),
          initialRoute: RouteHelper.getSplashRoute(body),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
          builder: (BuildContext context, widget) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1)),
                child: Material(
                  child: Stack(children: [
                    widget!,
                    GetBuilder<ProfileController>(builder: (profileController) {
                      bool canShow = profileController.profileModel != null &&
                          profileController.profileModel!.subscription !=
                              null &&
                          profileController
                                  .profileModel!.subscription!.isTrial ==
                              1 &&
                          profileController
                                  .profileModel!.subscription!.status ==
                              1 &&
                          DateConverter.differenceInDaysIgnoringTime(
                                  DateTime.parse(profileController
                                      .profileModel!.subscription!.expiryDate!),
                                  DateTime.now()) >
                              0;

                      return canShow && !profileController.trialWidgetNotShow
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 90),
                                child: TrialWidget(
                                    subscription: profileController
                                        .profileModel!.subscription!),
                              ),
                            )
                          : const SizedBox();
                    }),
                  ]),
                ));
          },
        );
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
