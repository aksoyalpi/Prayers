import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      title: Text(Strings.location["location"]!),
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
                child: const Text("GPS")),
            RadioMenuButton(
                value: false,
                groupValue: useGPS,
                onChanged: (value) => setState(() {
                      useGPS = value!;
                    }),
                child: const Text("City")),
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
                          labelText: Strings.location["city"]!,
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
                      labelText: Strings.location["country"]!,
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
          child: const Text(Strings.save),
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
          child: const Text(Strings.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
