import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import "package:location/location.dart";
import 'package:prayer_times/time.dart';

final prayerTimeZones = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];

int day = DateTime.now().day;
double? latitude;
double? longitude;
String city = "";

void main() {
  runApp(const MyApp());
}

Future<double> setLocation() async {
  var location = Location();

  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return -1;
  }

  var permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return -1;
    }
  }

  var currentLocation = await location.getLocation();
  longitude = currentLocation.longitude;
  latitude = currentLocation.latitude;
  return 0;
}


/// Get Prayer times by location
Future<Time> fetchPostByLocation() async {
  day = DateTime.now().day;
  final year = DateTime.now().year;
  final month = DateTime.now().month;

  await setLocation();
  var uri = Uri.parse(
      "http://api.aladhan.com/v1/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=13");

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return Time.fromJson(json.decode(response.body));
  } else {
    throw Exception("Failed to load Times");
  }
}


/// get prayertimes by city
Future<Time> fetchPostByCity() async {
  day = DateTime.now().day;
  final year = DateTime.now().year;
  final month = DateTime.now().month;

  Uri uri;

  if(city == "") city = "Hückelhoven";

  uri = Uri.parse(
      "http://api.aladhan.com/v1/calendarByCity/$year/$month?city=$city&country=Germany&method=13");

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return Time.fromJson(json.decode(response.body));
  } else {
    throw Exception("Failed to load Times");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MaterialApp(
          theme: ThemeData.dark(),
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
  Future<Time?>? time;

  void getTimeByLocation() {
    setState(() {
      time = fetchPostByLocation();
    });
  }

  void getTimesByCity() {
    setState(() {
      time = fetchPostByCity();
    });
  }

  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat.yMMMd('en_US').format(DateTime.now()),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            FutureBuilder(
                future: time,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.none) {
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
                      city = cityController.text;
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
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildDataWidget(context, snapshot) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var time in prayerTimeZones) prayerTimeWidget(time, snapshot)
        ],
      );

  /// Function to get prayertime for specified time
  ///
  /// time - Prayer time as text (Fajr, Dhuhr, ...);
  /// snapshot - whole data
  String getPrayerTime(snapshot, time) {
    return snapshot.data.data[day - 1]["timings"]["$time"]
        .toString()
        .split(" (")[0];
  }

  /// Function to return boolean if now is the time for the given parameter
  ///
  /// eg. if time is Dhuhr and the clock is between dhuhr and asr it should return
  /// true else false
  bool onTime(time, snapshot) {
    if (time == prayerTimeZones[1]) return false;

    int hour = DateTime.now().hour;
    int min = DateTime.now().minute;
    int prayerHour = int.parse(getPrayerTime(snapshot, time).split(":")[0]);
    int prayerMin = int.parse(getPrayerTime(snapshot, time).split(":")[1]);

    String nextTime = prayerTimeZones[0];
    for (int i = 0; i < prayerTimeZones.length - 1; i++) {
      if (time == prayerTimeZones[i]) {
        nextTime = prayerTimeZones[i + 1];
      }
    }

    int nextPrayerHour =
        int.parse(getPrayerTime(snapshot, nextTime).split(":")[0]);
    int nextPrayerMin =
        int.parse(getPrayerTime(snapshot, nextTime).split(":")[1]);

    if (time == prayerTimeZones[5]) {
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
  Widget prayerTimeWidget(time, snapshot) => Padding(
      padding: const EdgeInsets.all(10),
      child: Text("$time: ${getPrayerTime(snapshot, time)}",
          style: TextStyle(
              fontSize: 20,
              color: onTime(time, snapshot) ? Colors.green : Colors.white70)));

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
          foregroundColor: Colors.white70,
        ),
        onPressed:() => {
          if(city){
            getTimesByCity()
          } else {
            getTimeByLocation()
          }
        },
        child: Text(text),
      );
}
