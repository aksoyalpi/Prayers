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
      title: Text("Notifications"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
              if(notifications) {
                Notify.prayerTimesNotifiyAll(pt);
              } else {
                Notify.cancelNotifications();
              }
              Navigator.of(context).pop();
            },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],

    );
    return CupertinoAlertDialog(
      title: const Text(
        "Notifications",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
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
        CupertinoDialogAction(
            child: const Text("save"),
            onPressed: (){
              prefs.setBool("notifications", notifications);
              if(notifications) {
                Notify.prayerTimesNotifiyAll(pt);
              } else {
                Notify.cancelNotifications();
              }
              Navigator.of(context, rootNavigator: true).pop();
            }
        ),
        CupertinoDialogAction(
          child: const Text("cancel"),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),

        ),
      ],
    );
  }
}
