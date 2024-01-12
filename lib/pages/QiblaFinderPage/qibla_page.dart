import 'package:flutter/cupertino.dart';

class QiblaFinderPage extends StatefulWidget {
  const QiblaFinderPage({super.key});

  @override
  State<QiblaFinderPage> createState() => _QiblaFinderPageState();
}

class _QiblaFinderPageState extends State<QiblaFinderPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset("../assets/qibla-kompass.png", width: 200, height: 200,),
    );
  }
}
