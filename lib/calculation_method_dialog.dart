import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';
import 'main.dart';

final List<String> calcMethods = PrayerTimes.calcMethods;

class CalculationMethodDialog extends StatefulWidget {
  const CalculationMethodDialog({super.key});

  @override
  State<CalculationMethodDialog> createState() =>
      _CalculationMethodDialogState();
}

class _CalculationMethodDialogState extends State<CalculationMethodDialog> {
  String calcMethod = PrayerTimes
      .calcMethods[prefs.getInt(Strings.prefs["calculationMethod"]!)!];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(AppLocalizations.of(context)!.calculationMethod),
      content: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < calcMethods.length; i++)
              SizedBox(
                  height: 50,
                  child: RadioMenuButton(
                      value: calcMethods[i],
                      groupValue: calcMethod,
                      onChanged: (value) {
                        setState(() {
                          calcMethod = value!;
                        });
                      },
                      child: SizedBox(
                          width: 250,
                          child: Text(
                            calcMethods[i],
                            overflow: TextOverflow.fade,
                          )))),
          ]),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            prefs.setInt(Strings.prefs["calculationMethod"]!,
                calcMethods.indexOf(calcMethod));
            Navigator.of(context).pop(calcMethod);
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
