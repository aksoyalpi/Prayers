import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:prayer_times/main.dart';

class Notify {
  static Future<bool> prayerTimesNotify(String prayer, int hour, int min) async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          hour: hour,
          minute: min,
        ),
        content: NotificationContent(
            id: Random().nextInt(100),
            channelKey: 'prayer_notification',
            title: "$prayer: $hour:$min",
            body: "It is time for $prayer"));
  }

  static Future<bool> prayerTimesNotifiyAll() async {
    for(final time in prayerTimeZones) {
      // return prayerTimesNotify(time, hour, min)
    }
  }
}
