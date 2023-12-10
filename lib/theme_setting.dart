import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'consts/strings.dart';
import 'main.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  String appTheme = prefs.getString(Strings.theme["appTheme"]!)!, oldAppTheme = prefs.getString(Strings.theme["appTheme"]!)!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(Strings.theme["appTheme"]!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioMenuButton(
                value: Strings.theme["system"],
                groupValue: appTheme,
                onChanged: (value) {
                  setState(() => appTheme = value!);
                },
                child: Text(Strings.theme["system"]!)),
            RadioMenuButton(
                value: Strings.theme["light"],
                groupValue: appTheme,
                onChanged: (value) {
                  setState(() => appTheme = value!);
                },
                child: Text(Strings.theme["light"]!)),
            RadioMenuButton(
                value: Strings.theme["dark"],
                groupValue: appTheme,
                onChanged: (value) {
                  setState(() => appTheme = value!);
                },
                child: Text(Strings.theme["dark"]!)),
              if(oldAppTheme != appTheme) const Divider(),
              if (oldAppTheme != appTheme )Text("You have to restart the App to change the App theme.",
              style: GoogleFonts.lato(fontSize: 12),
            )
          ],
        ),
      actions: [
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            prefs.setString(Strings.theme["appTheme"]!, appTheme);
            Navigator.of(context).pop(appTheme);
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
