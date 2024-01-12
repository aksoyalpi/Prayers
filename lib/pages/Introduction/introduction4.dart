import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroductionPage4 extends StatelessWidget {
  const IntroductionPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.acceptDua,  textAlign: TextAlign.center,
                style: GoogleFonts.sevillana(fontSize: 30),
              ),
              Lottie.network("https://lottie.host/5b3af2f5-6c29-4c50-8972-c24daadb5aae/gVXUPUO4xK.json", height: 300, width: 300)
            ],
          ),
        ));
  }
}
