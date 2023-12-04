import 'package:flutter/cupertino.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MaterialApp(
          theme: ThemeData.light(),
          themeMode: ThemeMode.system,
          darkTheme: ThemeData.dark(),
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
    // TODO: implement initState
    super.initState();
    _notificationIcon =
        notificationIsOn() ? Icons.notifications : Icons.notifications_off;
  }

  bool notificationIsOn() {
    if (prefs.getBool("notifications")!) {
      return true;
    }
    return false;
  }

  void notify() {
    times?.then((value) async => {
          if (prefs.getBool("notifications")!)
            {await Notify.prayerTimesNotifiyAll(pt)}
        });
  }

  Future<void> getTimeByLocation() async {
    setState(() {
      times = pt.fetchPostByLocation();
    });
    notify();
  }

  void getTimesByCity() {
    setState(() {
      times = pt.fetchPostByCity();
    });
    notify();
  }

  void showSetting() {
    showDialog(
            context: context,
            builder: (context) => const Settings(),
            barrierDismissible: true)
        .then((value) => setState(() {
              _notificationIcon = notificationIsOn()
                  ? Icons.notifications
                  : Icons.notifications_off;
            }));
  }

  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                padding: const EdgeInsets.all(30),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => showSetting(),
                icon: Icon(_notificationIcon)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat.yMMMd('en_US').format(DateTime.now()),
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: TextField(
                      controller: cityController,
                      style: const TextStyle(color: Colors.white70),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        labelText: "City",
                      ),
                      onChanged: (String value) {
                        pt.city = cityController.text;
                      },
                    ),
                  ),
                  SizedBox(
                      height: 100,
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          getTimesButton("Get by city", true),
                          getTimesButton("Get by location", false)
                        ],
                      )),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildDataWidget(context, snapshot) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var time in PrayerTimes.prayerTimeZones)
            prayerTimeWidget(time, snapshot)
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
      width: 200,
      height: 50,
      child: Card(
          elevation: 10,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Align(
            alignment: AlignmentDirectional.center,
            child: onTime(time, snapshot)
                ? Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Radio(
                        fillColor: MaterialStateProperty.all(Colors.green),
                        value: true,
                        groupValue: true,
                        toggleable: false,
                        onChanged: (bool? value) {},
                      ),
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          "$time: ${pt.getPrayerTime(time)!.split(" ")[0]}",
                          style: GoogleFonts.lato(),
                        ),
                      )
                    ],
                  )
                : Text("$time: ${pt.getPrayerTime(time)!.split(" ")[0]}",
                    style: GoogleFonts.lato()

                    //TextStyle(
                    //  fontSize: 20,
                    //color: Colors.white70,
                    ),
          )));

  Color getBtnTxtColor() {
    // Get the current theme data
    ThemeData currentTheme = Theme.of(context);

    // Determine the text color based on the theme brightness
    Color btnTxtColor = currentTheme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return btnTxtColor;
  }

  /// personal button to get Times
  /// one button for searching with city name;
  /// other button for searching via location
  ///
  /// param:
  /// text - Text in Button;
  /// city - boolean if you should search by city
  Widget getTimesButton(String text, bool city) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          foregroundColor: getBtnTxtColor(),
        ),
        onPressed: () => {
          if (city) {getTimesByCity()} else {getTimeByLocation()}
        },
        child: Text(text),
      );
}
