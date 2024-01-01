import 'package:flutter/material.dart';
import 'package:prayer_times/pages/HomePage/home_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../consts/strings.dart';
import '../../location.dart';
import '../../main.dart';
import 'introduction1.dart';
import 'introduction2.dart';
import 'introduction3.dart';
import 'introduction4.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  bool? useGPS;
  final location = ValueNotifier(Location());

  // Controller to keep track of which page we're on
  final PageController _pageController = PageController();

  // keep track of if we are on the last page or not
  bool onLastPage = false;
  int pages = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                onLastPage = (value == pages-1);
              });
            },
            children: const [
              IntroductionPage1(),
              IntroductionPage2(),
              IntroductionPage3(),
              IntroductionPage4()
            ],
          ),

          // dot indicators
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(pages-1);
                    },
                    child: Text(AppLocalizations.of(context)!.skip)),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages,
                  onDotClicked: (index) => _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn),
                ),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          prefs.setBool(Strings.firstStart, false);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const MyHomePage();
                          }));
                        },
                        child: Text(AppLocalizations.of(context)!.done,
                            style: const TextStyle(color: Colors.blue)))
                    : GestureDetector(
                        onTap: () {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: Text(AppLocalizations.of(context)!.next))
              ],
            ),
          )
        ],
      ),
    );
  }
}
