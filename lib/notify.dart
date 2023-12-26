import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'consts/strings.dart';
import 'main.dart';
import 'pages/HomePage/notification_dialog.dart';


class Notify {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static String _timezone = "unknown";
  static List _notificationTypes = prefs.getStringList(Strings.notification)!;


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

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(time, time, importance: Importance.max);
    if(sound == "adhan"){
      androidNotificationDetails = AndroidNotificationDetails(
          time,
          time,
          importance: Importance.max,
          sound: const RawResourceAndroidNotificationSound("adhan")
      );
    }
    return NotificationDetails(
      android: androidNotificationDetails
      );
      // for Ios
      //ios: IOSNotificationDetails(),
  }

  static Future init({bool initScheduled = false}) async {
    const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    // TODO: IOS settings
    await _notifications.initialize(
        const InitializationSettings(android: androidSettings));

    if (initScheduled) {
      tz.initializeTimeZones();
      _timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(_timezone));
    }
  }

  static Future prayerTimesNotify(String time, int hour, int min) async {
    final index = PrayerTimes.prayerTimeZones.indexOf(time);
    String hourStr = hour < 10 ? "0$hour" : hour.toString();
    String minStr = min < 10 ? "0$min" : min.toString();

    DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, min);
    print(tz.TZDateTime.from(scheduledDate, tz.local).toString());

    if(scheduledDate.isAfter(DateTime.now())){
      _notifications.zonedSchedule(
          index, "$time: $hourStr:$minStr", "It's time for $time",
          tz.TZDateTime.from(scheduledDate, tz.local)
          , await _notificationDetails(time),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
              .absoluteTime,
          androidAllowWhileIdle: true);
    }
  }

  /// sends notification for all prayer times
  static Future<bool> prayerTimesNotifiyAll(PrayerTimes pt) async {
    cancelAll();
    _notificationTypes = prefs.getStringList(Strings.notification)!;
    for (int i = 0; i < PrayerTimes.prayerTimeZones.length; i++) {
      int j = i > 1 ? i-1 : i;
      String time = PrayerTimes.prayerTimeZones[i];
      if (i != 1 && _notificationTypes[j] != NotificationType.off.toString()) {
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
