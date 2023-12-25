import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'consts/strings.dart';
import 'pages/HomePage/main.dart';
import 'pages/HomePage/notification_dialog.dart';


class Notify {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Function to set notification setting for specific time
  static void setNotificationForSpecificTime(String time,
      NotificationType notificationType) {
    // TODO: for new notification package
  }

  static Future _notificationDetails(String time) async {
    List<String> prayers = PrayerTimes.prayerTimeZones;
    List<String> notificationTypes = prefs.getStringList(Strings.notification)!;
    int index = prayers.indexOf(time);
    int j = index > 1 ? index - 1 : index;
    bool soundOn = false;
    String? sound;
    if (notificationTypes[j] != NotificationType.off.toString()) {
      soundOn = true;
      if (notificationTypes[j] == NotificationType.adhan.toString()) {
        sound = "adhan";
      }
    }
    print("Created: ${prayers[index]}");

    return NotificationDetails(
      android: AndroidNotificationDetails(
          time,
          time,
          importance: Importance.max,
          playSound: soundOn,
        sound: RawResourceAndroidNotificationSound(sound)
      ),
      // for Ios
      //ios: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    // TODO: IOS settings
    await _notifications.initialize(
        const InitializationSettings(android: androidSettings));

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  static Future prayerTimesNotify(String time, int hour, int min) async {
    final index = PrayerTimes.prayerTimeZones.indexOf(time);
    String hourStr = hour < 10 ? "0$hour" : hour.toString();
    String minStr = min < 10 ? "0$min" : min.toString();

    DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, min);


    _notifications.show(index, "$time: $hourStr:$minStr", "It's time for $time",
        await _notificationDetails(time));
    _notifications.zonedSchedule(
        index, "$time: $hourStr:$minStr", "It's time for $time",
        tz.TZDateTime.from(scheduledDate, tz.local)
        , await _notificationDetails(time),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        androidAllowWhileIdle: true);

    /*return awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          hour: hour,
          minute: min,
        ),
        content: NotificationContent(
            id: index,
            channelKey: prayer,
            title: "$prayer: $hourStr:$minStr",
            body: "It's time for $prayer",
            wakeUpScreen: true,
            category: NotificationCategory.Reminder));*/
  }

  /// sends notification for all prayer times
  static Future<bool> prayerTimesNotifiyAll(PrayerTimes pt) async {
    for (var time in PrayerTimes.prayerTimeZones) {
      print(time);
      if (time != PrayerTimes.prayerTimeZones[1]) {
        await prayerTimesNotify(
            time, pt.getPrayerTimeHour(time), pt.getPrayerTimeMin(time));
      }
    }
    return true;
  }

  /// cancels scheduled Notifications
  static void cancel(int id) => _notifications.cancel(id);


  /// cancels all scheduled Notifications
  static void cancelAll() => _notifications.cancelAll();
}
