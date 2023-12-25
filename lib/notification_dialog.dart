import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'prayer_times.dart';
import 'consts/strings.dart';
import 'main.dart';

enum NotificationType { off, on, adhan }

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key, required this.time});

  final String time;

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  int index = 0;
  NotificationType aktType = NotificationType.off;
  @override
  void initState() {
    index = PrayerTimes.prayerTimeZones.indexOf(widget.time);
    if(index > 1) index--;
    aktType = NotificationType.values.firstWhere((element) =>
      element.toString() == prefs.getStringList(Strings.notification)![index], orElse: () => NotificationType.off);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${AppLocalizations.of(context)!.notification}: "),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioMenuButton(
              value: NotificationType.adhan,
              groupValue: aktType,
              onChanged: (value) {
                setState(() => aktType = value!);
              },
              child: Row(
                children: [
                  const Icon(Icons.notifications_active),
                  Text(" ${AppLocalizations.of(context)!.adhan}")
                ],
              )),
          RadioMenuButton(
              value: NotificationType.on,
              groupValue: aktType,
              onChanged: (value) {
                setState(() => aktType = value!);
              },
              child: Row(
                children: [
                  const Icon(Icons.notifications),
                  Text(" ${AppLocalizations.of(context)!.notification}")
                ],
              )),
          RadioMenuButton(
              value: NotificationType.off,
              groupValue: aktType,
              onChanged: (value) {
                setState(() => aktType = value!);
              },
              child: Row(
                children: [
                  const Icon(Icons.notifications_off),
                  Text(" ${AppLocalizations.of(context)!.off}")
                ],
              )),
        ],
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            Navigator.of(context).pop(aktType);
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
