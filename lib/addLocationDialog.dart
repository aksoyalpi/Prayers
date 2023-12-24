import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'consts/strings.dart';
import 'main.dart';


/// Dialog to add new city + country to the Appbar Menu
/// Returns: a List with City (0) and Country (1)
class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key});

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  String country = prefs.getString(Strings.prefs["country"]!)!;
  String city = prefs.getString(Strings.prefs["city"]!)!;

  @override
  Widget build(BuildContext context) {
    cityController.text = city;
    countryController.text = country;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.location),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: cityController,
                style: GoogleFonts.lato(),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  labelText: AppLocalizations.of(context)!.city,
                ),
                onChanged: (String value) {
                  city = cityController.text;
                },
              )),
          TextField(
            controller: countryController,
            style: GoogleFonts.lato(),
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              labelText: AppLocalizations.of(context)!.country,
            ),
            onChanged: (String value) {
              country = countryController.text;
            },
          )
        ],
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
              prefs.setString(Strings.prefs["city"]!, city);
              prefs.setString(Strings.prefs["country"]!, country);
            Navigator.of(context).pop([city, country]);
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
