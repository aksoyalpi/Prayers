import 'package:flutter/material.dart';
import 'package:prayer_times/pages/Settings/calculation_method_dialog.dart';
import 'package:prayer_times/pages/Settings/language_dialog.dart';
import 'package:prayer_times/location_dialog.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/settings_dialog.dart';
import 'package:prayer_times/pages/Settings/theme_setting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../../consts/strings.dart';
import '../../main.dart';

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
  // returns the country code of the saved languageCode
  String language = prefs.getString(Strings.languageCode)!;

  String calcMethod = PrayerTimes
      .calcMethods[prefs.getInt(Strings.prefs["calculationMethod"]!)!];

  String getLanguage(String value){
    const Map<String, String> langs = {
      "en": "English",
      "de": "Deutsch",
      "tr": "Türkçe"
    };
    return langs[value].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.settings),
        title: Text(AppLocalizations.of(context)!.settings),
        /*actions: [
          TextButton(
              onPressed: () => {Navigator.of(context).pop("save")},
              child: Text(AppLocalizations.of(context)!.save))
        ],*/
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.general),
            tiles: [
              /*SettingsTile.switchTile(
                initialValue: notificationOn,
                title: Text(AppLocalizations.of(context)!.notification),
                leading: const Icon(Icons.notifications),
                onToggle: (bool value) {
                  setState(() {
                    notificationOn = value;
                  });
                  prefs.setBool(Strings.notificationOn, value);
                },
              ),*/
              SettingsTile(
                  title: Text(AppLocalizations.of(context)!.language),
                description: Text(getLanguage(language)),
                leading: const Icon(Icons.language),
                onPressed: (context) => showDialog(
                    context: context,
                    builder: (context) => const LanguageDialog(),
                ).then((value) {
                  MyApp.of(context)!.setLocale(Locale(value!));
                  setState(() {
                    language = value!;
                  });
                }),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.appThemeTitle),
                description: Text(AppLocalizations.of(context)!.appTheme(aktTheme)),
                leading: const Icon(Icons.smartphone),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => const ThemeSetting(),
                  ).then((value) {
                    MyApp.of(context)?.setThemeMode(getThemeMode());
                    setState(() {
                      aktTheme = value;
                    });
                  });
                },
              ),
            ],
          ),
          SettingsSection(title: Text(AppLocalizations.of(context)!.prayerTimes), tiles: [
            SettingsTile(
              leading: const Icon(Icons.calculate),
              title: Text(AppLocalizations.of(context)!.calculationMethod),
              description: Text(calcMethod),
              onPressed: (context) => showDialog(
                context: context,
                builder: (context) => const CalculationMethodDialog(),
              ).then((value) {
                setState(() {
                  calcMethod = value!;
                });
              }),
            )
          ])
        ],
      ),
    ));
  }
}
