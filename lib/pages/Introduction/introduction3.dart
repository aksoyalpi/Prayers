import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class IntroductionPage3 extends StatelessWidget {
  const IntroductionPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          Text(
            AppLocalizations.of(context)!.notification,  textAlign: TextAlign.center,
            style: GoogleFonts.sevillana(fontSize: 30),
          ),
          const SizedBox(height: 50),
          Lottie.network("https://lottie.host/b26ea767-aac2-4d1c-955c-180c56861099/HkbeWIQwU0.json", height: 300, width: 300),
          const SizedBox(height: 50),
          SizedBox(
            width: 300,
            height: 125,
            child: Text(
                AppLocalizations.of(context)!.changeNotificationDescription
            )
          )
                ],
              ),
        ));
  }
}
