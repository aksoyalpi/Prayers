import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:prayer_times/main.dart';
import 'package:prayer_times/prayer_times.dart';

class Notify {
  static Future<bool> prayerTimesNotify(
      String prayer, int hour, int min) async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          hour: hour,
          minute: min,
        ),
        content: NotificationContent(
            id: 67,
            channelKey: 'prayer_notification',
            title: "$prayer: $hour:$min",
            body: "It is time for $prayer",
            wakeUpScreen: true,
            category: NotificationCategory.Message));
  }

  static Future<bool> prayerTimesNotifiyAll() async {
    PrayerTimes pt = PrayerTimes();
    for (final time in PrayerTimes.prayerTimeZones) {
      return prayerTimesNotify(
          time, pt.getPrayerTimeHour(time), pt.getPrayerTimeMin(time));
    }
    return true;
  }
}
