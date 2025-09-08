// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/helper/locale_helper.dart';

class DateConverter {
  static String formatDate(DateTime dateTime) {
    return LocaleHelper.formatDate(dateTime, 'yyyy-MM-dd');
  }

  static String formatDepositTime(DateTime dateTime) {
    return LocaleHelper.formatDate(dateTime, 'yyyy-MM-dd HH:mm:ss');
  }

  static String dateToTime(DateTime dateTime) {
    return LocaleHelper.formatDate(dateTime, _timeFormatter());
  }

  static String dateToDate(DateTime dateTime) {
    return DateFormat('dd-MMM-yyyy', LocaleHelper.getValidLocale()).format(dateTime);
  }

  static String dateToDateOnly(DateTime dateTime) {
    return DateFormat('dd-MM-yy', LocaleHelper.getValidLocale()).format(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    try {
      // Try standard DateTime parsing first
      return DateTime.parse(dateTime).toLocal();
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }

  static String isoToDate(String dateTime) {
    return DateFormat('dd/MM/yy', LocaleHelper.getValidLocale()).format(isoStringToLocalDate(dateTime));
  }

  static String isoToTime(String dateTime) {
    return LocaleHelper.formatDate(isoStringToLocalDate(dateTime), _timeFormatter());
  }

  static String isoToDateWithTime(String dateTime) {
    return DateFormat('dd-MM-yyyy HH:mm', LocaleHelper.getValidLocale())
        .format(isoStringToLocalDate(dateTime));
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat('dd MMM, yyyy  ${_timeFormatter()}', LocaleHelper.getValidLocale())
        .format(DateTime.parse(dateTime));
  }

  static String dateTimeStringToDate(String dateTime) {
    return DateFormat('dd MMM, yyyy', LocaleHelper.getValidLocale()).format(DateTime.parse(dateTime));
  }

  static DateTime dateTimeStringToDateOnly(String dateTime) {
    return LocaleHelper.parseDate(dateTime, 'yyyy-MM-dd') ?? DateTime.now();
  }

  static String convertDateToDate(String date) {
    return DateFormat('dd MMM yyyy', LocaleHelper.getValidLocale())
        .format(DateFormat('yyyy-MM-dd', LocaleHelper.getValidLocale()).parse(date));
  }

  static String dateTimeStringToMonthAndTime(String dateTime) {
    return DateFormat('dd MMM yyyy \nHH:mm a', LocaleHelper.getValidLocale()).format(DateTime.parse(dateTime));
  }

  static String dateTimeForCoupon(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd', LocaleHelper.getValidLocale()).format(dateTime);
  }

  static String utcToDateTime(String dateTime) {
    return DateFormat('dd MMM, yyyy h:mm a', LocaleHelper.getValidLocale())
        .format(DateTime.parse(dateTime).toLocal());
  }

  static String utcToDate(String dateTime) {
    return DateFormat('dd MMM, yyyy', LocaleHelper.getValidLocale()).format(DateTime.parse(dateTime));
  }

  static bool isAvailable(String? start, String? end,
      {DateTime? time, bool isoTime = false}) {
    DateTime currentTime;
    if (time != null) {
      currentTime = time;
    } else {
      currentTime = Get.find<SplashController>().currentTime;
    }
    DateTime start0 = start != null
        ? isoTime
            ? isoStringToLocalDate(start)
            : LocaleHelper.parseDate(start, 'HH:mm') ?? DateTime(currentTime.year)
        : DateTime(currentTime.year);
    DateTime end0 = end != null
        ? isoTime
            ? isoStringToLocalDate(end)
            : LocaleHelper.parseDate(end, 'HH:mm') ?? DateTime(
                currentTime.year, currentTime.month, currentTime.day, 23, 59)
        : DateTime(
            currentTime.year, currentTime.month, currentTime.day, 23, 59);
    DateTime startTime = DateTime(currentTime.year, currentTime.month,
        currentTime.day, start0.hour, start0.minute, start0.second);
    DateTime endTime = DateTime(currentTime.year, currentTime.month,
        currentTime.day, end0.hour, end0.minute, end0.second);
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel!.timeformat == '24'
        ? 'HH:mm'
        : 'hh:mm a';
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy ', LocaleHelper.getValidLocale())
        .format(dateTime.toLocal());
  }

  static String convert24HourTo12Hour(String time24) {
    DateTime tempDate = DateFormat("HH:mm", LocaleHelper.getValidLocale()).parse(time24);
    var dateFormat = DateFormat("h:mm a", LocaleHelper.getValidLocale());
    return dateFormat.format(tempDate);
  }

  static String convertStringTimeToDateTime(String time) {
    return DateFormat(_timeFormatter(), LocaleHelper.getValidLocale())
        .format(DateFormat('HH:mm:ss', LocaleHelper.getValidLocale()).parse(time));
  }

  static String dateToMonthAndYear(DateTime dateTime) {
    return DateFormat('MMM yyyy', LocaleHelper.getValidLocale()).format(dateTime);
  }

  static String scheduleTime(String? time) {
    return DateFormat(_timeFormatter(), LocaleHelper.getValidLocale())
        .format(DateFormat('HH:mm:ss', LocaleHelper.getValidLocale()).parse(time!));
  }

  static String stringToReadableTime(String time) {
    return DateFormat('hh:mm a', LocaleHelper.getValidLocale()).format(DateFormat('HH:mm', LocaleHelper.getValidLocale()).parse(time));
  }

  static String stringToStringTime(String time) {
    return DateFormat('HH:mm', LocaleHelper.getValidLocale()).format(DateFormat('hh:mm a', LocaleHelper.getValidLocale()).parse(time));
  }

  static String dateToIsoString(DateTime dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.mmm'Z'", LocaleHelper.getValidLocale()).format(dateTime.toUtc());
  }

  static String dateTimeStringToTimeOnly(String dateTime) {
    return DateFormat(_timeFormatter(), LocaleHelper.getValidLocale())
        .format(DateTime.parse(dateTime).toLocal());
  }

  static String tripSharingDate(String date) {
    return DateFormat('dd MMM, yyyy', LocaleHelper.getValidLocale()).format(DateTime.parse(date).toLocal());
  }

  static String tripSharingTime(String time) {
    return DateFormat("hh:mm a", LocaleHelper.getValidLocale()).format(DateTime.parse(time).toLocal());
  }

  static bool isBeforeTime(String time) {
    final now = DateTime.now();
    var inputTime = DateTime(now.year, now.month, now.day,
        int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));
    return inputTime.isBefore(now);
  }

  static DateTime formattingTripDateTime(
      DateTime pickedTime, DateTime pickedDate) {
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute);
  }

  static bool isSameDate(DateTime pickedTime) {
    return pickedTime.year == DateTime.now().year &&
        pickedTime.month == DateTime.now().month &&
        pickedTime.day == DateTime.now().day &&
        pickedTime.hour == DateTime.now().hour;
  }

  static bool isAfterCurrentDateTime(DateTime pickedTime) {
    DateTime pick = DateTime(pickedTime.year, pickedTime.month, pickedTime.day,
        pickedTime.hour, pickedTime.minute);
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
    return pick.isAfter(current);
  }

  static String getDayName(int day) {
    switch (day) {
      case 0:
        return 'sunday'.tr;
      case 1:
        return 'monday'.tr;
      case 2:
        return 'tuesday'.tr;
      case 3:
        return 'wednesday'.tr;
      case 4:
        return 'thursday'.tr;
      case 5:
        return 'friday'.tr;
      case 6:
        return 'saturday'.tr;
      default:
        return '';
    }
  }

  static TimeOfDay stringToTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]));
  }

  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static int differenceInDaysIgnoringTime(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return aDate.difference(bDate).inDays;
  }

  static String dayDateTime(String dateTime) {
    final dt = DateTime.parse(dateTime);
    return DateFormat('EEEE, dd MMM yyyy – HH:mm', LocaleHelper.getValidLocale()).format(dt);
  }

  static String localDateToMonthDateSince(DateTime dateTime) {
    return DateFormat('MMM yyyy', LocaleHelper.getValidLocale()).format(dateTime);
  }

  static String convertStringTimeToTime(String time) {
    // Converts 'hh:mm a' <-> 'HH:mm' as needed
    try {
      if (time.contains('AM') ||
          time.contains('PM') ||
          time.contains('am') ||
          time.contains('pm')) {
        return DateFormat('HH:mm', LocaleHelper.getValidLocale()).format(DateFormat('hh:mm a', LocaleHelper.getValidLocale()).parse(time));
      } else {
        return DateFormat('hh:mm a', LocaleHelper.getValidLocale()).format(DateFormat('HH:mm', LocaleHelper.getValidLocale()).parse(time));
      }
    } catch (_) {
      return time;
    }
  }
}
