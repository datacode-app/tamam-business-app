// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/notification/domain/models/notification_model.dart';
import 'package:tamam_business/features/notification/domain/services/notification_service_interface.dart';
import 'package:tamam_business/helper/date_converter_helper.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList;

  bool _hasNotification = false;
  bool get hasNotification => _hasNotification;

  Future<void> getNotificationList() async {
    List<NotificationModel>? notificationList =
        await notificationServiceInterface.getNotificationList();
    if (notificationList != null) {
      _notificationList = [];
      _notificationList!.addAll(notificationList);
      _notificationList!.sort((NotificationModel n1, NotificationModel n2) {
        return DateConverter.dateTimeStringToDate(n1.createdAt!)
            .compareTo(DateConverter.dateTimeStringToDate(n2.createdAt!));
      });
      _notificationList = _notificationList!.reversed.toList();
      _hasNotification =
          _notificationList!.length != getSeenNotificationCount();
    }
    update();
  }

  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
  }
}
