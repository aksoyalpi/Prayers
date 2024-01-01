import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class IntroductionPage1 extends StatefulWidget {
  const IntroductionPage1({super.key});

  @override
  State<IntroductionPage1> createState() => _IntroductionPage1State();
}

class _IntroductionPage1State extends State<IntroductionPage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Esselamu aleykum ve Rahmetullahi", textAlign: TextAlign.center ,style: GoogleFonts.sevillana(fontSize: 30),),
        const SizedBox(height: 50),
        Lottie.network("https://lottie.host/f39a2c01-4800-49f4-b281-7516e0e62287/4ExSO5l9oA.json"),
        const SizedBox(height: 100,)
      ],
    ));
  }
}
