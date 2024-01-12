import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/pages/HomePage/prayer_times_page.dart';
import 'package:prayer_times/pages/QiblaFinderPage/qibla_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        items:  const [
          FaIcon(FontAwesomeIcons.personPraying),
          FaIcon(FontAwesomeIcons.compass),
          Icon(Icons.settings_outlined)
        ],),
      body: [
        const PrayerTimesPage(),
        QiblaPage(),
        const Settings(),
      ][pageIndex],
    );
  }
}
