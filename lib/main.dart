import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prayer_times/time.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const MyApp());
}

final prayerTimeZones = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];

int day = DateTime.now().day;


// GET Prayer Times from API
Future<Time> fetchPost() async {
  day = DateTime.now().day;
  final year = DateTime.now().year;
  final month = DateTime.now().month;
  final uri = Uri.parse(
      "http://api.aladhan.com/v1/calendarByCity/$year/$month?city=Hückelhoven&country=Germany&method=13");
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
          theme: ThemeData.light(),
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
  Future<Time?>? time;

  void clickGetButton() {
    setState(() {
      time = fetchPost();
    });
  }

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
            SizedBox(
                width: 150,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: const Color(0xFFBE71EF)),
                  onPressed: () => clickGetButton(),
                  child: const Text("GET"),
                ))
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

  String getPrayerTime(snapshot, time) {
    return snapshot.data.data[day - 1]["timings"]["$time"]
        .toString()
        .split("(")[0];
  }

  bool onTime(time, snapshot) {
    if(time == prayerTimeZones[1]) return false;

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
    int nextPrayerMin = int.parse(getPrayerTime(snapshot, time).split(":")[1]);


    if(time == prayerTimeZones[5]){
      nextPrayerMin = 59;
      nextPrayerHour = 23;
    }
    if (hour > prayerHour && hour < nextPrayerHour) {
      return true;
    } else if (hour == prayerHour && min >= prayerMin) {
      return true;
    } else if (hour > prayerHour &&
        hour == nextPrayerHour &&
        min < nextPrayerMin) {
      return true;
    }
    return false;
  }

  Widget prayerTimeWidget(time, snapshot) => Padding(
      padding: const EdgeInsets.all(10),
      child: Text("$time: ${getPrayerTime(snapshot, time)}",
          style: TextStyle(
              fontSize: 20,
              color: onTime(time, snapshot) ? Colors.green :  Colors.white70)));
}
