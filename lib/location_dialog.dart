import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';
import 'main.dart';

class LocationSettings extends StatefulWidget {
  const LocationSettings({super.key});

  @override
  State<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  String country = prefs.getString(Strings.prefs["country"]!)!;
  String city = prefs.getString(Strings.prefs["city"]!)!;
  bool useGPS = prefs.getBool(Strings.prefs["useGPS"]!)!;

  @override
  Widget build(BuildContext context) {
    cityController.text = city;
    countryController.text = country;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.location),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioMenuButton(
                value: true,
                groupValue: useGPS,
                onChanged: (value) => setState(() {
                      useGPS = value!;
                    }),
                child: Text(AppLocalizations.of(context)!.gps)),
            RadioMenuButton(
                value: false,
                groupValue: useGPS,
                onChanged: (value) => setState(() {
                      useGPS = value!;
                    }),
                child: Text(AppLocalizations.of(context)!.city)),
            if (!useGPS)
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: TextField(
                        controller: cityController,
                        style: GoogleFonts.lato(),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          labelText: AppLocalizations.of(context)!.city,
                        ),
                        onChanged: (String value) {
                          city = cityController.text;
                        },
                      )),
                  TextField(
                    controller: countryController,
                    style: GoogleFonts.lato(),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      labelText: AppLocalizations.of(context)!.country,
                    ),
                    onChanged: (String value) {
                      country = countryController.text;
                    },
                  )
                ],
              ),
          ]),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            prefs.setBool(Strings.prefs["useGPS"]!, useGPS);
            if(!useGPS){
              prefs.setString(Strings.prefs["city"]!, city);
              prefs.setString(Strings.prefs["country"]!, country);
            }
            Navigator.of(context)
                .pop(useGPS);
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
