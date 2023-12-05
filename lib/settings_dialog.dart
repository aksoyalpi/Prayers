import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'notify.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool notifications = prefs.getBool("notifications")!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Notifications"),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioMenuButton(
                value: true,
                groupValue: notifications,
                onChanged: (value) => setState(() {
                  notifications = value!;
                }),
                child: const Text("On")),
            RadioMenuButton(
                value: false,
                groupValue: notifications,
                onChanged: (value) => setState(() {
                  notifications = value!;
                }),
                child: const Text("Off")),
          ]),
      actions: [
        TextButton(
          child: const Text('Save'),
            onPressed: (){
              prefs.setBool("notifications", notifications);
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
