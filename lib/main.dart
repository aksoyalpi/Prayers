import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:prayer_times/pages/HomePage/notification_dialog.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/pages/Settings/settings.dart';
import 'package:prayer_times/time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'pages/HomePage/addLocationDialog.dart';
import 'Location.dart';
import 'consts/strings.dart';
import 'notify.dart';

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
  if (!prefs.containsKey(Strings.notification)) {
    List<String> notificationTypes = List.generate(
        5, growable: false, (index) => NotificationType.adhan.toString());
    prefs.setStringList(Strings.notification, notificationTypes);
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final double futureContainerHeight = 400.0;
  String locationAppBar = prefs.getBool("useGPS")!
      ? "GPS"
      : prefs.getString(Strings.prefs["city"]!)!;
  Future<Time?>? times;
  DateTime date = DateTime.now();
  var hijri = JHijri.now();
  List<String> locationStrings = prefs.getStringList(Strings.locations)!;
  List<Location> locations = [];
  List<PopupMenuItem> locationsPopUpItems = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setTimes();
      for (String akt in locationStrings) {
        locations.add(Location.fromString(akt));
      }
      setState(() {});
    });
    Notify.init(initScheduled: true);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setTimes();
      setState(() {
        times = times;
      });
    }
  }

  /// Function that checks the condition and sets the time to a new one or get it from the prefs
  void setTimes() {
    List<String> savedTimes = prefs.getStringList(Strings.prayerTimes)!;
    if (savedTimes.isEmpty ||
        prefs.getInt(Strings.aktDay) != DateTime.now().day) {
      prefs.setInt(Strings.aktDay, DateTime.now().day);
      setState(() {
        times = pt.fetchPost(prefs.getBool("useGPS")!);
      });
      setCheckboxesFalse();
      times?.then(
          (value) {
            prefs.setStringList(Strings.prayerTimes, value!.toList());
            Notify.prayerTimesNotifiyAll(pt);
          });
      ;
    }
  }

  /// Function that changes times parameter wihout checking conditions
  /// see also setTimes()
  void setTimesDefinitely() {
    setState(() {
      times = pt.fetchPost(prefs.getBool("useGPS")!);
    });
    times?.then(
        (value) {
          prefs.setStringList(Strings.prayerTimes, value!.toList());
          Notify.prayerTimesNotifiyAll(pt);
        });
    ;
  }

  /// Returns bool if notification is on
  bool notificationIsOn() {
    if (prefs.getBool(Strings.notificationOn)!) {
      return true;
    }
    return false;
  }

  /// Function for prayer notifications if notifications are on else they get cancelled
  void notify() {
    if (!notificationIsOn()) {
      Notify.cancelAll();
      return;
    }
    bool alreadyNotificated = false;
    times?.then((value) async =>
        {if (!alreadyNotificated) await Notify.prayerTimesNotifiyAll(pt)});
  }

  /// Show Settings dialog
  void showSettings() {
    showDialog(context: context, builder: (context) => const Settings())
        .then((value) {
      setState(() {
        times = pt.fetchPost(prefs.getBool(Strings.prefs["useGPS"]!)!);
      });
      times?.then(
          (value) async {
            prefs.setStringList(Strings.prayerTimes, value!.toList());
            await Notify.prayerTimesNotifiyAll(pt);
          });
    });
  }

  /// Funktion beim runterziehen
  Future _refresh() async {
    setState(() {
      times = pt.fetchPost(prefs.getBool(Strings.prefs["useGPS"]!)!);
    });
    times?.then((value) {
      if (value != null) {
        prefs.setStringList(Strings.prayerTimes, value.toList());
      }
    });
    return times;
  }

  /// Funtction that is called when user clicks on arrow left or right to see the next day or the day before
  void changeDate(int day) {
    DateTime tmpDate = date.add(Duration(days: day));
    setState(() {
      date = tmpDate;
      hijri = JHijri(fDate: tmpDate);
      times =
          pt.fetchPostByDate(prefs.getBool(Strings.prefs["useGPS"]!)!, date);
    });
  }

  void changeDateByDatePicker() async {
    DateTime? tmpTime = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (tmpTime != null) {
      setState(() {
        date = tmpTime;
        hijri = JHijri(fDate: tmpTime);
        times =
            pt.fetchPostByDate(prefs.getBool(Strings.prefs["useGPS"]!)!, date);
      });
    }
  }

  void addNewLocation() {
    showDialog(
        context: context,
        builder: (context) => const AddLocationDialog()).then((value) {
          if(value != null){
            Location location = Location.fromList(value);
            locationStrings.add("${location.city}, ${location.country}");
            prefs.setStringList(Strings.locations, locationStrings);
            prefs.setString(Strings.prefs["city"]!, location.city);
            prefs.setString(Strings.prefs["country"]!, location.country);
            locations.add(location);
            setTimesDefinitely();
            setState(() {
              locationStrings = locationStrings;
              locations = locations;
              locationAppBar = location.city;
            });
          }
    });
  }

  /// Helpermethod for the Appbars Location Menu
  void changeLocation(var value) {
    bool useGPS = prefs.getBool("useGPS")!;
    if (value == -1 && !useGPS) {
      prefs.setBool("useGPS", true);
      setState(() {
        locationAppBar = AppLocalizations.of(context)!.gps;
      });
    } else {
      prefs.setBool("useGPS", false);
      Location location = locations[value];
      prefs.setString(Strings.prefs["city"]!, location.city);
      prefs.setString(Strings.prefs["country"]!, location.country);
      setState(() {
        locationAppBar = location.city;
      });
    }
    setTimesDefinitely();
    setState(() {});
  }

  /// Function to delete one location out of the list
  void deleteLocation(String location) {
    List<String> tmpLocationString = locationStrings;
    int indexOfLocation = tmpLocationString.indexOf(location);
    print(indexOfLocation);
    tmpLocationString.removeAt(indexOfLocation);
    List<Location> tmpLocations = locations;
    tmpLocations.removeAt(indexOfLocation);

    prefs.setStringList(Strings.locations, tmpLocationString);
    setState(() {
      locationStrings = tmpLocationString;
      locations = tmpLocations;
    });
    if (locations.isEmpty) {
      setState(() {
        locationAppBar = AppLocalizations.of(context)!.gps;
      });
    }
    Navigator.pop(context);
  }

  List<PopupMenuItem> generatePopups() {
    List<PopupMenuItem> popups = [];
    popups.add(const PopupMenuItem(
        value: -1,
        child: Row(
          children: [Icon(Icons.location_on), Text(" GPS")],
        )));
    for (int i = 0; i < locationStrings.length; i++) {
      PopupMenuItem popup = PopupMenuItem(
          value: i,
          child: CityPopupItem(
            deleteCallBack: (String location) {
              deleteLocation(location);
            },
            location: locationStrings[i],
          ));
      popups.add(popup);
    }
    if (locations.length < 5) {
      popups.add(PopupMenuItem(
        onTap: () => addNewLocation(),
        child: const Icon(Icons.add_circle_outline),
      ));
    }
    return popups;
  }

  @override
  Widget build(BuildContext context) {
    locationsPopUpItems = generatePopups();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: PopupMenuButton(
              onSelected: (value) => changeLocation(value),
              initialValue: locationStrings.indexOf(
                  "${prefs.getString(Strings.prefs["city"]!)}, ${prefs.getString(Strings.prefs["country"]!)}"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(locationAppBar,
                          style: GoogleFonts.lato(fontSize: 18))),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
              itemBuilder: (context) => locationsPopUpItems),
          actions: [
            IconButton(
                style: ButtonStyle(iconSize: MaterialStateProperty.all(25)),
                padding: const EdgeInsets.symmetric(vertical: 5),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => showSettings(),
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                changeDate(-1);
              } else if (details.primaryVelocity! < 0) {
                changeDate(1);
              }
            },
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: RefreshIndicator(
                    onRefresh: () => _refresh(),
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () => changeDate(-1),
                                        child: Text(
                                          "< ",
                                          style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    GestureDetector(
                                      onTap: () => changeDateByDatePicker(),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .date(date),
                                            style: GoogleFonts.lato(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${hijri.monthName} ${hijri.day}, ${hijri.year}",
                                            style:
                                                GoogleFonts.lato(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () => changeDate(1),
                                        child: Text(" >",
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              FutureBuilder(
                                      key: UniqueKey(),
                                      future: times,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox(
                                              height: futureContainerHeight,
                                              child: const Center(
                                                  child: SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child:
                                                          CircularProgressIndicator())));
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.none) {
                                          return SizedBox(
                                              height: futureContainerHeight);
                                        } else {
                                          if (snapshot.hasData) {
                                            return buildDataWidget(
                                                context, snapshot, date);
                                          } else if (snapshot.hasError) {
                                            return Text("${snapshot.error}");
                                          } else {
                                            return SizedBox(
                                              height: futureContainerHeight,
                                            );
                                          }
                                        }
                                      })
                            ])))))));
  }

  Widget buildDataWidget(context, snapshot, DateTime date) => Column(
        key: UniqueKey(),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var time in PrayerTimes.prayerTimeZones)
            if (!dateIsToday(date) ||
                time != PrayerTimes.prayerTimeZones[1] ||
                pt.getPrayerTimeHour(time) > DateTime.now().hour ||
                (pt.getPrayerTimeHour(time) >= DateTime.now().hour &&
                    pt.getPrayerTimeMin(time) >= DateTime.now().minute))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: PrayerTime(
                    time: time, snapshot: snapshot, selectedDate: date),
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
  final DateTime selectedDate;

  const PrayerTime(
      {super.key,
      required this.time,
      required this.snapshot,
      required this.selectedDate});

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

bool dateIsToday(DateTime date) {
  return (date.day == DateTime.now().day &&
      date.month == DateTime.now().month &&
      date.year == DateTime.now().year);
}

/// Function to return boolean if now is the time for the given parameter
///
/// eg. if time is Dhuhr and the clock is between dhuhr and asr it should return
/// true else false
bool onTime(String time, snapshot, DateTime date) {
  if (!dateIsToday(date)) return false;
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

  void showNotificationDialog(String time) {
    if (time != PrayerTimes.prayerTimeZones[1]) {
      showDialog(
        context: context,
        builder: (context) => NotificationDialog(time: time),
      ).then((notificationType) async {
        if (notificationType != null) {
          int index = PrayerTimes.prayerTimeZones.indexOf(time);
          if (index > 1) index--;
          List<String> notificationTypes =
              prefs.getStringList(Strings.notification)!;
          notificationTypes[index] = notificationType.toString();
          prefs.setStringList(Strings.notification, notificationTypes);
          await Notify.prayerTimesNotifiyAll(pt);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            isChecked = !isChecked!;
          });
          prefs.setBool(widget.time, isChecked!);
        },
        onLongPress: () => showNotificationDialog(widget.time),
        child: SizedBox(
            width: 320,
            height: 65,
            child: Card(
                surfaceTintColor: Theme.of(context).cardColor,
                shadowColor:
                    onTime(widget.time, widget.snapshot, widget.selectedDate)
                        ? Colors.green
                        : Theme.of(context).shadowColor,
                elevation: 12,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (onTime(
                        widget.time, widget.snapshot, widget.selectedDate))
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
                    if (widget.time != PrayerTimes.prayerTimeZones[1] &&
                        dateIsToday(widget.selectedDate))
                      Positioned(
                          right: 10,
                          child: Checkbox(
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            value: dateIsToday(widget.selectedDate)
                                ? isChecked
                                : false,
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

class CityPopupItem extends StatelessWidget {
  const CityPopupItem(
      {super.key, required this.location, required this.deleteCallBack});

  final deleteCallBack;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 150, child: Text(location)),
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            onPressed: () => deleteCallBack(location),
            icon: const Icon(Icons.delete)),
      )
    ]);
  }
}
