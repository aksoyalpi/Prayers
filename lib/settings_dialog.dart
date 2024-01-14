import 'package:flutter/material.dart';

import 'main.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool notificationsisOns = prefs.getBool("notifications")!;

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
                groupValue: notificationsisOns,
                onChanged: (value) => setState(() {
                  notificationsisOns = value!;
                }),
                child: const Text("On")),
            RadioMenuButton(
                value: false,
                groupValue: notificationsisOns,
                onChanged: (value) => setState(() {
                  notificationsisOns = value!;
                }),
                child: const Text("Off")),
          ]),
      actions: [
        TextButton(
          child: const Text('Save'),
            onPressed: (){
              prefs.setBool("notifications", notificationsisOns);
              Navigator.of(context).pop(notificationsisOns);
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
