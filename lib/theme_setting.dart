import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.appThemeTitle),
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
                child: Text(AppLocalizations.of(context)!.system)),
            RadioMenuButton(
                value: Strings.theme["light"],
                groupValue: appTheme,
                onChanged: (value) {
                  setState(() => appTheme = value!);
                },
                child: Text(AppLocalizations.of(context)!.light)),
            RadioMenuButton(
                value: Strings.theme["dark"],
                groupValue: appTheme,
                onChanged: (value) {
                  setState(() => appTheme = value!);
                },
                child: Text(AppLocalizations.of(context)!.dark)),
              if(oldAppTheme != appTheme) const Divider(),
              if (oldAppTheme != appTheme )Text(AppLocalizations.of(context)!.restartAppToChangeTheme,
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            prefs.setString(Strings.theme["appTheme"]!, appTheme);
            Navigator.of(context).pop(appTheme);
          },
        ),
        TextButton(
          child:  Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
