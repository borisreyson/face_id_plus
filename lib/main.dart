
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:face_id_plus/loading.dart';
import 'package:face_id_plus/services/location_service.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'dart:io' show Platform;

import 'package:provider/provider.dart';

Future main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
          return StreamProvider(initialData:UserLocation(-0.5634222, 117.0139606),create: (BuildContext context) { LocationService().locationStream; },
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: _mainPage()
          ));

  }
  _mainPage(){
    if(Platform.isAndroid){
      return AnimatedSplashScreen(splash: Image.asset('assets/images/ic_abp.png'),duration: 1500,splashTransition: SplashTransition.scaleTransition, nextScreen: Loading());
      // Splash();
    }else if(Platform.isIOS){
      return AnimatedSplashScreen(splash: Image.asset('assets/images/ic_abp.png'),duration: 1500,splashTransition: SplashTransition.scaleTransition, nextScreen: Loading());
    }
  }
}
