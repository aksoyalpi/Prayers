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

  String location = prefs.getString(Strings.prefs["location"]!)!;
  bool useCity = prefs.getString(Strings.prefs["location"]!) == "" ? false : true;

  @override
  Widget build(BuildContext context) {
    cityController.text = location;

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
                value: false,
                groupValue: useCity,
                onChanged: (value) => setState(() {
                      useCity = value!;
                    }),
                child: const Text("GPS")),
            RadioMenuButton(
                value: true,
                groupValue: useCity,
                onChanged: (value) => setState(() {
                      useCity = value!;
                    }),
                child: const Text("City")),
            if (useCity)
              Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: TextField(
                    controller: cityController,
                    style: GoogleFonts.lato(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      labelText: "City",
                    ),
                    onChanged: (String value) {
                      location = cityController.text;
                    },
                  )),
          ]),
      actions: [
        TextButton(
          child: const Text(Strings.save),
          onPressed: () {
            useCity ? prefs.setString(Strings.prefs["location"]!, location) : prefs.setString(Strings.prefs["location"]!, "");
            Navigator.of(context).pop(useCity? location : Strings.location["gps"]);
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
