import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';
import 'main.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  late Locale aktLocale = Locale(prefs.getString(Strings.languageCode)!);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioMenuButton(
              value: const Locale("en"),
              groupValue: aktLocale,
              onChanged: (value) {
                setState(() => aktLocale = const Locale("en"));
              },
              child: Text(AppLocalizations.of(context)!.english)),
          RadioMenuButton(
              value: const Locale("tr"),
              groupValue: aktLocale,
              onChanged: (value) {
                setState(() => aktLocale = const Locale("tr"));
              },
              child: Text(AppLocalizations.of(context)!.turkish)),
          RadioMenuButton(
              value: const Locale("de"),
              groupValue: aktLocale,
              onChanged: (value) {
                setState(() => aktLocale = const Locale("de"));
              },
              child: Text(AppLocalizations.of(context)!.german)),
        ],
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            prefs.setString(Strings.languageCode, aktLocale.toLanguageTag());
            Navigator.of(context).pop(aktLocale.toLanguageTag());
          },
        ),
        TextButton(
          child:  Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
