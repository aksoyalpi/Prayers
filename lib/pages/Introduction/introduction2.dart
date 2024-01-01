import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:prayer_times/pages/Introduction/introduction_page.dart';

import '../../consts/strings.dart';
import '../../main.dart';

class IntroductionPage2 extends StatefulWidget {
  const IntroductionPage2({super.key});

  @override
  State<IntroductionPage2> createState() => _IntroductionPage2State();
}

class _IntroductionPage2State extends State<IntroductionPage2> {
  final List<String> languages = ["English", "Türkce", "Deutsch"];
  final List<String> locales = ["en", "tr", "de"];

  late int chosen;

  @override
  void initState() {
    if(!prefs.containsKey("chosenLanguage")) {
      prefs.setInt("chosenLanguage", 0);
      chosen = 0;
    } else {
      chosen = prefs.getInt("chosenLanguage")!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.chooseLanguage,  textAlign: TextAlign.center,
              style: GoogleFonts.sevillana(fontSize: 30)),
          SizedBox(
            height: 500,
            child: GridView.count(
                //physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: List.generate(
                    languages.length,
                    (index) => GestureDetector(
                          onTap: () {
                            prefs.setInt("chosenLanguage", index);
                            prefs.setString(Strings.languageCode, locales[index]);
                            setState(() {
                              chosen = index;
                            });
                            MyApp.of(context)
                                ?.setLocale(Locale(locales[index]));
                          },
                          child: Card(
                              elevation: index == chosen ? 12 : 1,
                              child: Center(child: Text(languages[index], style: const TextStyle(fontSize: 18),))),
                        ))),
          )
        ],
      ),
    );
  }
}
