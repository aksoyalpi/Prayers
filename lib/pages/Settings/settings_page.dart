import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:prayer_times/pages/Settings/calculation_method_dialog.dart';
import 'package:prayer_times/pages/Settings/language_dialog.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:prayer_times/pages/Settings/theme_setting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

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

  String getLanguage(String value) {
    const Map<String, String> langs = {
      "en": "English",
      "de": "Deutsch",
      "tr": "Türkçe"
    };
    return langs[value].toString();
  }

  // Function to share the App
  Future<void> _shareApp() async {
    // Set the app link and the message to be shared
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.alaksoftware.prayer_times';
    const String message = 'Check out Prayers: $appLink';
    print(message);
    // Share the app link and message using the share dialog
    Share.share(message);
  }

  Future<void> _giveFeedback() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.settings),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SettingsList(
        sections: [
          // General Section
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.general),
            tiles: [
              // language settings
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

              // App theme settings
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.appThemeTitle),
                description:
                    Text(AppLocalizations.of(context)!.appTheme(aktTheme)),
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

          // Support Section (share, donate, feedback)
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.prayerTimes),
              tiles: [
                // calculation method setting
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
              ]),

          // Support Section (Feedback, share App, Donate)
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.support),
              tiles: [
                // Share App Tile
                SettingsTile(
                    leading: const Icon(Icons.ios_share_outlined),
                    title:
                        Text(AppLocalizations.of(context)!.share_with_friends),
                    onPressed: (context) => _shareApp()),

                // Feedback Tile
                SettingsTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: Text(AppLocalizations.of(context)!.feedback),
                    onPressed: (context) => _giveFeedback())
              ]),
        ],
      ),
    ));
  }
}
