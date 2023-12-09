import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'consts/strings.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  String appTheme = "System";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Theme"),
        RadioMenuButton(
            value: Strings.theme["system"],
            groupValue: appTheme,
            onChanged: (value) => {},
            child: Text(Strings.theme["system"]!)),
        RadioMenuButton(
            value: Strings.theme["light"],
            groupValue: appTheme,
            onChanged: (value) => {},
            child: Text(Strings.theme["light"]!)),
        RadioMenuButton(
            value: Strings.theme["dark"],
            groupValue: appTheme,
            onChanged: (value) => {},
            child: Text(Strings.theme["dark"]!)),
      ],
    );
  }
}
