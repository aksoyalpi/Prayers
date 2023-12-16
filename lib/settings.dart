import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/calculation_method_dialog.dart';
import 'package:prayer_times/location_dialog.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/settings_dialog.dart';
import 'package:prayer_times/theme_setting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'consts/strings.dart';
import 'main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool notificationOn = prefs.getBool(Strings.notificationOn)!;
  String aktTheme = prefs.getString(Strings.theme["appTheme"]!)!;
  bool useGPS = prefs.getBool(Strings.prefs["useGPS"]!)!;
  String city = prefs.getString(Strings.prefs["city"]!)!;
  String country = prefs.getString(Strings.prefs["country"]!)!;

  String calcMethod = PrayerTimes
      .calcMethods[prefs.getInt(Strings.prefs["calculationMethod"]!)!];

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.settings),
        title: const Text(Strings.settings),
        actions: [
          TextButton(
              onPressed: () => {Navigator.of(context).pop("save")},
              child: const Text(Strings.save))
        ],
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text(Strings.general),
            tiles: [
              SettingsTile.switchTile(
                initialValue: notificationOn,
                title: const Text(Strings.notification),
                leading: const Icon(Icons.notifications),
                onToggle: (bool value) {
                  setState(() {
                    notificationOn = value;
                  });
                  prefs.setBool(Strings.notificationOn, value);
                },
              ),
              SettingsTile(
                title: Text(Strings.theme["appTheme"]!),
                description: Text(aktTheme),
                leading: const Icon(Icons.smartphone),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => const ThemeSetting(),
                  ).then((value) {
                    setState(() {
                      aktTheme = value;
                    });
                  });
                },
              ),
            ],
          ),
          SettingsSection(title: const Text(Strings.prayerTimes), tiles: [
            SettingsTile(
              title: Text(Strings.location["location"]!),
              leading: const Icon(Icons.location_on),
              description:
                  Text(useGPS ? Strings.location["gps"]! : "$city, $country"),
              onPressed: (context) => showDialog(
                context: context,
                builder: (context) => const LocationSettings(),
              ).then((value) {
                setState(() {
                  useGPS = value;
                });
              }),
            ),
            SettingsTile(
              leading: const Icon(Icons.calculate),
              title: const Text(Strings.calculation_method),
              description: Text(calcMethod),
              onPressed: (context) => showDialog(
                context: context,
                builder: (context) => const CalculationMethodDialog(),
              ).then((value) {
                setState(() {
                  calcMethod = value;
                });
              }),
            )
          ])
        ],
      ),
    ));
  }
}
