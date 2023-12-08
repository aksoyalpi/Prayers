import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';
import 'notify.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  TextEditingController cityController = TextEditingController();

  String location = prefs.getString("location")!;
  bool useCity = prefs.getString("location") == "" ? false : true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Location"),
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
          child: const Text('Save'),
          onPressed: () {
            useCity ? prefs.setString("location", location) : prefs.setString("location", "");
            Navigator.of(context).pop("save");
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
