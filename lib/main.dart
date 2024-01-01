import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/pages/HomePage/home_page.dart';
import 'package:prayer_times/pages/HomePage/notification_dialog.dart';
import 'package:prayer_times/pages/Introduction/introduction_page.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';

PrayerTimes pt = PrayerTimes();
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  AndroidFlutterLocalNotificationsPlugin().requestNotificationsPermission();
  AndroidFlutterLocalNotificationsPlugin().requestExactAlarmsPermission();

  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(Strings.prefs["calculationMethod"]!)) {
    prefs.setInt(Strings.prefs["calculationMethod"]!, 12);
  }
  if (!prefs.containsKey(Strings.notification)) {
    List<String> notificationTypes = List.generate(
        5, growable: false, (index) => NotificationType.adhan.toString());
    prefs.setStringList(Strings.notification, notificationTypes);
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
  if (!prefs.containsKey(Strings.aktDay)) {
    prefs.setInt(Strings.aktDay, DateTime.now().day);
    setCheckboxesFalse();
  }
  if (!prefs.containsKey(Strings.languageCode)) {
    prefs.setString(Strings.languageCode, "en");
  }
  if (!prefs.containsKey(Strings.prayerTimes)) {
    prefs.setStringList(Strings.prayerTimes, []);
  }
  if (!prefs.containsKey(Strings.locations)) {
    prefs.setStringList(Strings.locations, []);
  }

  // requestPermissionToSendNotifications
  runApp(const MyApp());
  // declaring Notification

}

void setCheckboxesFalse() {
  for (int i = 0; i < PrayerTimes.prayerTimeZones.length; i++) {
    if (i != 1) {
      prefs.setBool(PrayerTimes.prayerTimeZones[i], false);
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = getThemeMode();
  Locale _locale = Locale(prefs.getString(Strings.languageCode)!);

  @override
  void initState() {
    super.initState();
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  void setThemeMode(ThemeMode value) {
    setState(() {
      _themeMode = value;
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
          home: prefs.containsKey(Strings.firstStart) ? const MyHomePage() : const IntroductionPage(),
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

