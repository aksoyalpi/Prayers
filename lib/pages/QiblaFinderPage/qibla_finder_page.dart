import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaFinderPage extends StatefulWidget {
  const QiblaFinderPage({super.key});

  @override
  State<QiblaFinderPage> createState() => _QiblaFinderPageState();
}

class _QiblaFinderPageState extends State<QiblaFinderPage> {
  bool hasPermission = false;

  Future getPermission() async {
    if(await Permission.location.serviceStatus.isEnabled){
      final status = await Permission.location.status;
      if(status.isGranted){
        hasPermission = true;
      } else {
        Permission.location.request().then((value){
          setState(() {
            hasPermission = (value == PermissionStatus.granted);
          });
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    getPermission();
    return FutureBuilder(
        future: getPermission(),
        builder: (context, snapshot){
          if(hasPermission){
            return const QiblaScreen();
          } else {
            return const Scaffold();
          }
        },);
  }
}


class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? _animationController;
  double begin = 0.0;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FlutterQiblah.qiblahStream,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting || snapshot.data == null){
            return const Center(child: CircularProgressIndicator());
          }

          final qiblaDirection = snapshot.data!;
          animation = Tween(begin: begin, end: qiblaDirection.qiblah * (pi / 180) *-1).animate(_animationController!);
          begin = (qiblaDirection.qiblah * (pi / 180) * -1);
          _animationController?.forward(from: 0);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${qiblaDirection.direction.toInt()}°", style: const TextStyle(fontSize: 24),),
                const SizedBox(height: 25,),
                SizedBox(
                  height: 300,
                  child: AnimatedBuilder(
                      animation: animation!,
                      builder: (context, child) => Transform.rotate(
                        angle: animation!.value,
                        child: Image.asset("assets/qibla-kompass.png"),
                      ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}

