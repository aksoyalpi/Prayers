import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/location_dialog.dart';
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
  String aktLocation = prefs.getString(Strings.prefs["location"]!)!;

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
          SettingsSection(
            title: Text(Strings.location["location"]!),
              tiles: [
                SettingsTile(
                  title: Text(Strings.location["location"]!),
                  leading: const Icon(Icons.location_on),
                  description: Text(aktLocation == "" ? Strings.location["gps"]! : aktLocation),
                  onPressed: (context) => showDialog(
                    context: context,
                    builder: (context) => const LocationSettings(),
                  ).then((value){
                    setState(() {
                      aktLocation = value;
                    });
                  }),
                )
              ]
          )
        ],
      ),
    ));
  }
}
