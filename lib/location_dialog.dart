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
  String location = /*prefs.getString("location")!*/ "Hückelhoven";
  bool isCity = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Location"),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioMenuButton(
                value: false,
                groupValue: isCity,
                onChanged: (value) => setState(() {
                  isCity = value!;
                }),
                child: const Text("GPS")
            ),
            RadioMenuButton(
                value: true,
                groupValue: isCity,
                onChanged: (value) => setState(() {
                  isCity = value!;
                }),
                child: const Text("City")
            ),
            if(isCity)
              SizedBox(
                width: 250,
                height: 50,
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
                    pt.city = cityController.text;
                  },
                ),
              ),
          ]),
      actions: [
        TextButton(
          child: const Text('Save'),
          onPressed: (){
            // TODO: Save changes
            Navigator.of(context).pop();
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
