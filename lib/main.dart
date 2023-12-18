import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/settings.dart';
import 'package:prayer_times/settings_dialog.dart';
import 'package:prayer_times/time.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';
import 'notify.dart';
import 'location_dialog.dart';

PrayerTimes pt = PrayerTimes();
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AwesomeNotifications().requestPermissionToSendNotifications();

  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(Strings.prefs["calculationMethod"]!)) {
    prefs.setInt(Strings.prefs["calculationMethod"]!, 12);
  }
  if (!prefs.containsKey(Strings.prefs["useGPS"]!)) {
    prefs.setBool(Strings.prefs["useGPS"]!, true);
  }
  if (!prefs.containsKey(Strings.prefs["city"]!)) {
    prefs.setString(Strings.prefs["city"]!, "");
  }
  if (!prefs.containsKey(Strings.prefs["country"]!)) {
    prefs.setString(Strings.prefs["country"]!, "");
  }
  if (!prefs.containsKey(Strings.notificationOn)) {
    prefs.setBool(Strings.notificationOn, true);
  }
  if (!prefs.containsKey(Strings.aktDay) ||
      prefs.getInt(Strings.aktDay) != DateTime.now().day) {
    prefs.setInt(Strings.aktDay, DateTime.now().day);
    for (int i = 0; i < PrayerTimes.prayerTimeZones.length; i++) {
      if (i != 1) {
        prefs.setBool(PrayerTimes.prayerTimeZones[i], false);
      }
    }
  }
  if(!prefs.containsKey(Strings.languageCode)){
    prefs.setString(Strings.languageCode, "en");
  }

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  final ThemeMode _themeMode = getThemeMode();
  Locale _locale = const Locale("en");

  @override
  void initState() {
    super.initState();
  }

  void setLocale(Locale value){
    setState(() {
      _locale = value;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Prayers',
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo[700],
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: MaterialApp(
          title: "Prayers",
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(useMaterial3: true),
          themeMode: _themeMode,
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: const MyHomePage(),
        ));
  }
}

/// Function to get set Theme mode from stored value
ThemeMode getThemeMode() {
  if (!prefs.containsKey(Strings.theme["appTheme"]!)) {
    prefs.setString(Strings.theme["appTheme"]!, Strings.theme["system"]!);
    return ThemeMode.system;
  }
  switch (prefs.getString(Strings.theme["appTheme"]!)) {
    case "System":
      return ThemeMode.system;
    case "Light":
      return ThemeMode.light;
    case "Dark":
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Time?>? times;

  @override
  void initState() {
    times = pt.fetchPost(prefs.getBool("useGPS")!);
    notify();
    super.initState();
  }

  bool notificationIsOn() {
    if (prefs.getBool(Strings.notificationOn)!) {
      return true;
    }
    return false;
  }

  /// Function for prayer notifications if notifications are on else they get cancelled
  void notify() {
    if (!notificationIsOn()) {
      Notify.cancelNotifications();
      return;
    }
    bool alreadyNotificated = false;
    Notify.retrieveScheduledNotifications()
        .then((value) => alreadyNotificated = value.isNotEmpty);
    times?.then((value) async =>
        {if (!alreadyNotificated) await Notify.prayerTimesNotifiyAll(pt)});
  }

  /// Show Location dialog
  void showLocationSetting() {
    showDialog(
            context: context,
            builder: (context) => const LocationSettings(),
            barrierDismissible: true)
        .then((value) {
      if (value != "") {
        setState(() {
          times = pt.fetchPost(prefs.getBool(Strings.prefs["useGPS"]!)!);
        });
        notify();
      }
    });
  }

  /// Show Settings dialog
  void showSettings() {
    showDialog(context: context, builder: (context) => const Settings())
        .then((value) {
      setState(() {
        times = pt.fetchPost(prefs.getBool(Strings.prefs["useGPS"]!)!);
      });
      notify();
    });
  }

  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
                style: ButtonStyle(iconSize: MaterialStateProperty.all(25)),
                padding: const EdgeInsets.symmetric(vertical: 5),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => showSettings(),
                icon: const Icon(Icons.settings)),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                  top: 50,
                  child: Text(
                    /*DateFormat.yMMMd('en_US').format(DateTime.now())*/
                    AppLocalizations.of(context)!.date(DateTime.now()),
                    style: GoogleFonts.lato(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  )),
              Align(
                alignment: Alignment.center,
                child: FutureBuilder(
                    key: UniqueKey(),
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
              ),
            ],
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: PrayerTime(time: time, snapshot: snapshot),
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
}

/// Widget for one Prayer time (eg. Dhuhr)
///
/// time - Prayer time (Fajr, Dhuhr, ...);
/// snapshot - data
class PrayerTime extends StatefulWidget {
  final time;
  final snapshot;

  const PrayerTime({
    super.key,
    required this.time,
    required this.snapshot,
  });

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

/// Function to return boolean if now is the time for the given parameter
///
/// eg. if time is Dhuhr and the clock is between dhuhr and asr it should return
/// true else false
bool onTime(time, snapshot) {
  if (time == PrayerTimes.prayerTimeZones[1]) return false;

  int hour = DateTime.now().hour;
  int min = DateTime.now().minute;
  int prayerHour = pt.getPrayerTimeHour(time);
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

class _PrayerTimeState extends State<PrayerTime> {
  late bool? isChecked = prefs.getBool(widget.time);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            isChecked = !isChecked!;
          });
          prefs.setBool(widget.time, isChecked!);
        },
        child: SizedBox(
            width: 320,
            height: 65,
            child: Card(
                surfaceTintColor: Theme.of(context).cardColor,
                shadowColor: onTime(widget.time, widget.snapshot)
                    ? Colors.green
                    : Theme.of(context).shadowColor,
                elevation: 12,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (onTime(widget.time, widget.snapshot))
                      Positioned(
                        left: 0,
                        child: Transform.scale(
                            scale: 0.75,
                            child: Radio(
                              fillColor:
                                  MaterialStateProperty.all(Colors.green),
                              value: true,
                              groupValue: true,
                              toggleable: false,
                              onChanged: (bool? value) {},
                            )),
                      ),
                    Positioned(
                      left: 40,
                      child: Text(
                          /*widget.time*/
                          "${AppLocalizations.of(context)!.prayerTime(widget.time)} / ${Strings.prayersArabic[widget.time]}",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(fontSize: 12))),
                    ),
                    Positioned(
                        right: 55,
                        child: Text(
                          pt.getPrayerTime(widget.time)!,
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(fontSize: 12)),
                        )),
                    if (widget.time != PrayerTimes.prayerTimeZones[1])
                      Positioned(
                          right: 10,
                          child: Checkbox(
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                              prefs.setBool(widget.time, value!);
                            },
                          ))
                  ],
                ))));
  }
}
