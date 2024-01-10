import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/pages/HomePage/prayer_times_page.dart';
import 'package:prayer_times/pages/QiblaFinderPage/qibla_page.dart';

import 'Settings/settings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).backgroundColor,
        color: Colors.black26,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        items: const [
          Icon(Icons.mosque_outlined),
          Icon(Icons.not_listed_location_outlined),
          Icon(Icons.settings_outlined)
        ],),
      body: [
        PrayerTimesPage(),
        QiblaFinderPage(),
        Settings(),
      ][pageIndex],
    );
  }
}
