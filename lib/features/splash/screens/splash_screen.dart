// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/auth/controllers/auth_controller.dart';
import 'package:tamam_business/features/dashboard/screens/dashboard_screen.dart';
import 'package:tamam_business/features/notification/domain/models/notification_body_model.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/features/rental_module/chat/screens/taxi_chat_screen.dart';
import 'package:tamam_business/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:tamam_business/features/rental_module/trips/screens/trip_details_screen.dart';
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/helper/route_helper.dart';
import 'package:tamam_business/util/app_constants.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/images.dart';
import 'package:tamam_business/util/styles.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  void _route() {
    debugPrint('====> Starting splash screen routing');
    
    Get.find<SplashController>().getConfigData().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        debugPrint('====> Config API call timed out, using fallback routing');
        return false;
      },
    ).then((isSuccess) async {
      debugPrint('====> Config API call result: $isSuccess');
      
      if (isSuccess) {
        try {
          Timer(const Duration(seconds: 1), () async {
            try {
              double? minimumVersion = _getMinimumVersion();
              bool isMaintenanceMode = Get.find<SplashController>().configModel?.maintenanceMode ?? false;
              bool needsUpdate = minimumVersion != null && AppConstants.appVersion < minimumVersion;

              if (needsUpdate || isMaintenanceMode) {
                Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
              } else {
                if(widget.body != null) {
                  await _handleNotificationRouting(widget.body);
                } else {
                  await _handleDefaultRouting();
                }
              }
            } catch (e) {
              debugPrint('====> Error in version check/routing: $e');
              await _handleFallbackRouting();
            }
          });
        } catch (e) {
          debugPrint('====> Error setting up timer: $e');
          await _handleFallbackRouting();
        }
      } else {
        debugPrint('====> Config failed, using fallback routing');
        await _handleFallbackRouting();
      }
    }).catchError((error) {
      debugPrint('====> Config API error: $error');
      _handleFallbackRouting();
    });
  }

  Future<void> _handleFallbackRouting() async {
    debugPrint('====> Executing fallback routing');
    Timer(const Duration(seconds: 1), () async {
      try {
        if(widget.body != null) {
          await _handleNotificationRouting(widget.body);
        } else {
          await _handleDefaultRouting();
        }
      } catch (e) {
        debugPrint('====> Error in fallback routing: $e');
        // Last resort - go to sign in screen
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  double? _getMinimumVersion() {
    try {
      final configModel = Get.find<SplashController>().configModel;
      if (configModel == null) {
        debugPrint('====> Config model is null, using default version');
        return 0;
      }
      
      if (GetPlatform.isAndroid) {
        return configModel.appMinimumVersionAndroid ?? 0;
      } else if (GetPlatform.isIOS) {
        return configModel.appMinimumVersionIos ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('====> Error getting minimum version: $e');
      return 0;
    }
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? notificationBody) async {
    final notificationType = notificationBody?.notificationType;
    
    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TripDetailsScreen(tripId: notificationBody!.orderId!, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody?.orderId, fromNotification: true));
        }
      },
      NotificationType.advertisement: () => Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody?.advertisementId, fromNotification: true)),
      NotificationType.block: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.unblock: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.withdraw: () => Get.to(const DashboardScreen(pageIndex: 3)),
      NotificationType.campaign: () => Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: notificationBody?.campaignId, fromNotification: true)),
      NotificationType.message: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TaxiChatScreen(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }
      },
      NotificationType.subscription: () => Get.toNamed(RouteHelper.getMySubscriptionRoute(fromNotification: true)),
      NotificationType.product_approve: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
      NotificationType.product_rejected: () => Get.toNamed(RouteHelper.getPendingItemRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      Get.find<AuthController>().getModuleType() == 'rental' ? await Get.find<TaxiProfileController>().getProfile() : await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      final bool showIntro = Get.find<SplashController>().showIntro();
      if(AppConstants.languages.length > 1 && showIntro) {
        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
      }else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(Images.logo, width: 200),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('suffix_name'.tr, style: robotoMedium, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
