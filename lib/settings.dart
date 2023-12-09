import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/theme_setting.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return const Dialog.fullscreen(
      child: Column(
        children: [
          ThemeSetting()
        ],
      ),
    );
  }
}
