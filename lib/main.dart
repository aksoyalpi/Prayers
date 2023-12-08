import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/settings_dialog.dart';
import 'package:prayer_times/time.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notify.dart';
import 'location_dialog.dart';

// TODO: check out of bounds
// TODO: 30 (day) is out of bounds better: day-1

PrayerTimes pt = PrayerTimes();
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AwesomeNotifications().requestPermissionToSendNotifications();

  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("notification")) prefs.setBool("notifications", true);
  // requestPermissionToSendNotifications
  runApp(const MyApp());
  // declaring Notification
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'reminders',
            channelKey: 'prayer_notification',
            channelName: 'Prayer notifications',
            channelDescription: 'Notification channel for prayer times',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      debug: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Prayer Times',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo[700],
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          themeMode: ThemeMode.system,
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Time?>? times;
  late IconData _notificationIcon;

  @override
  void initState() {
    super.initState();
    _notificationIcon =
        notificationIsOn() ? Icons.notifications : Icons.notifications_off;
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          if(!prefs.containsKey("location")){
            prefs.setString("location", "");
            showLocationSetting();
          } else {
            setState(() {
              times = pt.fetchPost(prefs.getString("location")!);
            });
          }
    });
  }

  bool notificationIsOn() {
    if (prefs.getBool("notifications")!) {
      return true;
    }
    return false;
  }

  /// Function for prayer notifications if notifications are on
  void notify() {
    bool alreadyNotificated = false;
    Notify.retrieveScheduledNotifications()
        .then((value) => alreadyNotificated = value.isNotEmpty);
    times?.then((value) async => {
          if (prefs.getBool("notifications")! && !alreadyNotificated)
            await Notify.prayerTimesNotifiyAll(pt)
        });
  }


  /// show setting dialog
  void showNotificationSetting() {
    showDialog(
            context: context,
            builder: (context) => const Settings(),
            barrierDismissible: true)
        .then((value) async {
      setState(() {
        _notificationIcon =
            notificationIsOn() ? Icons.notifications : Icons.notifications_off;
      });
      notify();
    });
  }

  /// Show Location dialog
  void showLocationSetting() {
    showDialog(
        context: context,
        builder: (context) => const Location(),
        barrierDismissible: true
    ).then((value) {
      if(value == "save"){
        setState(() {
          times = pt.fetchPost(prefs.getString("location")!);
        });
      }
    });
  }

  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30, top: 30),
            child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => showNotificationSetting(),
                        icon: Icon(_notificationIcon)
                    ),
                    IconButton(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () => showLocationSetting(),
                      icon: const Icon(Icons.location_on),
                    )
                  ],
                )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.yMMMd('en_US').format(DateTime.now()),
                style: GoogleFonts.lato(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                  future: times,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return Container();
                    } else {
                      if (snapshot.hasData) {
                        return buildDataWidget(context, snapshot);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      } else {
                        return Container();
                      }
                    }
                  }),
            ],
          )
        ],
      ),
    );
  }

  Widget buildDataWidget(context, snapshot) => Column(
    key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var time in PrayerTimes.prayerTimeZones)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: prayerTimeWidget(time, snapshot),
            )
          //prayerTimeWidget(time, snapshot)
        ],
      );

  /// Function to get prayertime for specified time
  ///
  /// time - Prayer time as text (Fajr, Dhuhr, ...);
  /// snapshot - whole data
  String getPrayerTime(snapshot, time) {
    return snapshot.data.data[pt.day - 1]["timings"]["$time"]
        .toString()
        .split(" (")[0];
  }

  /// Function to return boolean if now is the time for the given parameter
  ///
  /// eg. if time is Dhuhr and the clock is between dhuhr and asr it should return
  /// true else false
  bool onTime(time, snapshot) {
    if (time == PrayerTimes.prayerTimeZones[1]) return false;

    int hour = DateTime.now().hour;
    int min = DateTime.now().minute;
    int prayerHour = pt.getPrayerTimeHour(
        time); //int.parse(getPrayerTime(snapshot, time).split(":")[0]);
    int prayerMin = pt.getPrayerTimeMin(time);

    String nextTime = PrayerTimes.prayerTimeZones[0];
    for (int i = 0; i < PrayerTimes.prayerTimeZones.length - 1; i++) {
      if (time == PrayerTimes.prayerTimeZones[i]) {
        nextTime = PrayerTimes.prayerTimeZones[i + 1];
      }
    }

    int nextPrayerHour = pt.getPrayerTimeHour(nextTime);
    int nextPrayerMin = pt.getPrayerTimeMin(nextTime);

    if (time == PrayerTimes.prayerTimeZones[5]) {
      nextPrayerMin = 59;
      nextPrayerHour = 23;
    }

    if (hour > prayerHour && hour < nextPrayerHour) {
      return true;
    } else if (hour == prayerHour && min >= prayerMin) {
      return true;
    } else if (hour == nextPrayerHour && min < nextPrayerMin) {
      return true;
    }
    return false;
  }

  /// Widget for one Prayer time (eg. Dhuhr)
  ///
  /// time - Prayer time (Fajr, Dhuhr, ...);
  /// snapshot - data
  Widget prayerTimeWidget(time, snapshot) => SizedBox(
      width: 300,
      height: 60,
      child: Card(
          surfaceTintColor: Theme.of(context).cardColor,
          shadowColor: onTime(time, snapshot) ? Colors.green : Theme.of(context).shadowColor,
          elevation: 12,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Align(
              alignment: AlignmentDirectional.center,
              child: onTime(time, snapshot)
                  ? Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Transform.scale(
                          scale: 0.75,
                          child: Radio(
                            fillColor: MaterialStateProperty.all(Colors.green),
                            value: true,
                            groupValue: true,
                            toggleable: false,
                            onChanged: (bool? value) {},
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("$time", style: GoogleFonts.lato()),
                            Text(
                              pt.getPrayerTime(time)!,
                              style: GoogleFonts.lato(),
                            )
                          ],
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("$time", style: GoogleFonts.lato()),
                        Text(
                          pt.getPrayerTime(time)!,
                          style: GoogleFonts.lato(),
                        )
                      ],
                    ))));

}
