import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:prayer_times/prayer_times.dart';

import 'main.dart';
import 'notification_dialog.dart';

class Notify {
  static void initialize(List<String> notificationTypes) {
    List<String> prayers = PrayerTimes.prayerTimeZones;
    List<NotificationChannel> channels = [];
    for (int i = 0; i < prayers.length; i++) {
      if (i != 1) {
        int j = i > 1 ? i-1 : i;
        bool soundOn = false;
        String? sound;
        if(notificationTypes[j] != NotificationType.off.toString()){
          soundOn = true;
          if(notificationTypes[j] == NotificationType.adhan.toString()){
            sound = "../assets/Hafiz Mustafa Öztürk from Turkey.mp3";
          }
        }
        channels.add(NotificationChannel(
            channelGroupKey: prayers[i],
            channelKey: prayers[i],
            channelName: prayers[i],
            channelDescription: 'Notification channel for ${prayers[i]}',
            playSound: soundOn,
            soundSource: sound
        ));
      }
    }
    AwesomeNotifications().initialize(null, channels);
  }


  /// Function to set notification setting for specific time
  static void setNotificationForSpecificTime(String time,
      NotificationType notificationType) {
    bool soundOn = false;
    String? soundSource;
    if (notificationType != NotificationType.off) {
      soundOn = true;
      if (notificationType == NotificationType.adhan) {
        soundSource = "../assets/Hafiz Mustafa Öztürk from Turkey.mp3";
      }
    }

    AwesomeNotifications().removeChannel(time);
    AwesomeNotifications().setChannel(NotificationChannel(
      playSound: soundOn,
        soundSource: soundSource,
        channelKey: time,
        channelName: time,
        channelDescription: 'Notification channel for $time'));
  }


  static Future<bool> prayerTimesNotify(String prayer, int hour,
      int min) async {
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
            channelKey: prayer,
            title: "$prayer: $hourStr:$minStr",
            body: "It's time for $prayer",
            wakeUpScreen: true,
            category: NotificationCategory.Reminder)
    );
  }

  /// sends notification for all prayer times
  static Future<bool> prayerTimesNotifiyAll(PrayerTimes pt) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return false;

    for (var time in PrayerTimes.prayerTimeZones) {
      if (time != PrayerTimes.prayerTimeZones[1]) {
        await prayerTimesNotify(
            time, pt.getPrayerTimeHour(time), pt.getPrayerTimeMin(time));
      }
    }
    return true;
  }

  /// cancels all scheduled Notifications
  static void cancelNotifications() {
    AwesomeNotifications().cancelAllSchedules();
  }

  /// Function to get a List of all scheduled Notifications
  static Future<
      List<NotificationModel>> retrieveScheduledNotifications() async {
    final AwesomeNotifications an = AwesomeNotifications();
    return await an.listScheduledNotifications();
  }
}
