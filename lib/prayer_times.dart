import 'dart:convert';

import 'package:location/location.dart';
import 'package:prayer_times/time.dart';
import 'package:http/http.dart' as http;

import 'Notify.dart';

class PrayerTimes {
  static final prayerTimeZones = [
    "Fajr",
    "Sunrise",
    "Dhuhr",
    "Asr",
    "Maghrib",
    "Isha"
  ];

  int day = 0;
  Future<Time?>? time;
  Time? times;
  double? latitude;
  double? longitude;
  String city = "";

  PrayerTimes() {
    day = DateTime.now().day;
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
  Future<Time?>? fetchPostByLocation() async {
    day = DateTime.now().day;
    final year = DateTime.now().year;
    final month = DateTime.now().month;

    await setLocation();
    var uri = Uri.parse(
        "http://api.aladhan.com/v1/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=13");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Notify.prayerTimesNotifiyAll();
      times = Time.fromJson(json.decode(response.body), day);
      return Time.fromJson(json.decode(response.body), day);
    } else {
      throw Exception("Failed to load Times");
    }
  }

  /// get prayertimes by city
  Future<Time?>? fetchPostByCity() async {
    day = DateTime.now().day;
    final year = DateTime.now().year;
    final month = DateTime.now().month;

    Uri uri;

    if (city == "") throw Exception("Please Enter a city");


    uri = Uri.parse(
        "http://api.aladhan.com/v1/calendarByCity/$year/$month?city=$city&country=Germany&method=13");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Notify.prayerTimesNotifiyAll();
      times = Time.fromJson(json.decode(response.body), day);
      return Time.fromJson(json.decode(response.body), day);
    } else {
      throw Exception("Failed to load Times");
    }
  }


  /// Method to get the prayertime for given param time
  String? getPrayerTime(String time){
    switch(time){
      case "Fajr":
        return times?.fajr;
        break;
      case "Sunrise":
        return times?.sunrise;
        break;
      case "Dhuhr":
        return times?.dhuhr;
        break;
      case "Asr":
        return times?.asr;
        break;
      case "Maghrib":
        return times?.maghrib;
        break;
      case "Isha":
        return times?.isha;
        break;
    }
    return "";
  }

  /// Method to just get the hour of the given prayertime as int
  int getPrayerTimeHour(String time){
    return int.parse(getPrayerTime(time)!.substring(0, 2));
  }


  /// Method to just get the minutes of the given prayertime as int
  int getPrayerTimeMin(String time){
    return int.parse(getPrayerTime(time)!.substring(3, 5));
  }
}
