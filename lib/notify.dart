import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:prayer_times/prayer_times.dart';

class Notify {
  static Future<bool> prayerTimesNotify(
      String prayer, int hour, int min) async {
    final index = PrayerTimes.prayerTimeZones.indexOf(prayer);
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    String hourStr = hour < 10 ? "0$hour" : hour.toString();
    String minStr = min < 10 ? "0$min" : min.toString();
    return awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          hour: hour,
          minute: min,
        ),
        content: NotificationContent(
            id: index,
            channelKey: 'prayer_notification',
            title: "$prayer: $hourStr:$minStr",
            body: "It's time for $prayer",
            wakeUpScreen: true,
            category: NotificationCategory.Reminder)
    );
  }

  /// sends notification for all prayer times
  static Future<bool> prayerTimesNotifiyAll(PrayerTimes pt) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    if (!isAllowed) return false;

    for (var time in PrayerTimes.prayerTimeZones) {
      if (time != PrayerTimes.prayerTimeZones[1]){
        await prayerTimesNotify(time, pt.getPrayerTimeHour(time), pt.getPrayerTimeMin(time));
      }
    }
    return true;
  }

  /// cancels all scheduled Notifications
  static void cancelNotifications(){
    AwesomeNotifications().cancelAllSchedules();
  }

  /// Function to get a List of all scheduled Notifications
  static Future<List<NotificationModel>> retrieveScheduledNotifications() async {
    final AwesomeNotifications an = AwesomeNotifications();
    return await an.listScheduledNotifications();
  }
}
