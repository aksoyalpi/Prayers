import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_times.dart';

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
      title: const Text(Strings.calculation_method),
      content: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              calcMethods.length,
              (index) => RadioMenuButton(
                  value: calcMethods[index],
                  groupValue: calcMethod,
                  onChanged: (value) {
                    setState(() {
                      calcMethod = value!;
                    });
                  },
                  child: Flexible(
                    child: Text(
                      calcMethods[index],
                      overflow: TextOverflow.fade,
                    ),
                  )))),
      actions: [
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            prefs.setInt(Strings.prefs["calculationMethod"]!,
                calcMethods.indexOf(calcMethod));
            Navigator.of(context).pop(calcMethod);
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
