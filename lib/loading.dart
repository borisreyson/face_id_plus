import 'dart:io' show Platform;
import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as iosLocation;
// import 'package:permission/permission.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';

int isLogin = 0;
bool _serviceEnabled = false;

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  late iosLocation.PermissionStatus _permissionGranted;
  late iosLocation.LocationData _locationData;
  iosLocation.Location location = iosLocation.Location();
  @override
  void initState() {
    if (Platform.isIOS) {
      _permissionCheck();
    } else if (Platform.isAndroid) {
      setState(() {
        _requestLocation();
      });
    } else {
      print("error Permission");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin") ?? 0;
    print("LoginStatus $isLogin");

    if (isLogin == 1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Splash()));
    }
  }

  _permissionCheck() async {
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == iosLocation.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != iosLocation.PermissionStatus.granted) {
        return;
      } else if(_permissionGranted==iosLocation.PermissionStatus.granted) {
        print("Permission is $_permissionGranted");

      }
    }else{
        print("Permission is $_permissionGranted");
    }
    print("Permission $_permissionGranted");

    _locationData = await location.getLocation();
  }

  _requestLocation() async {
    var status = await handler.Permission.location.status;
    var camStat = await handler.Permission.camera.status;
    var storage = await handler.Permission.storage.status;
    Map<handler.Permission, handler.PermissionStatus> _statuses = await [
      handler.Permission.location,
      handler.Permission.locationAlways,
      handler.Permission.locationWhenInUse,
      handler.Permission.storage,
      handler.Permission.manageExternalStorage,
      handler.Permission.camera,
      handler.Permission.microphone,
      handler.Permission.phone
    ].request();
    _statuses.forEach((key, value) {
      print("permission ${key}  - ${value}");
    });

    // print("Permission Status : $status");
    // if (status.isDenied) {
    //   print("Permission Status ABC");
    //   return handler.openAppSettings();
    // }
    // if (status.isPermanentlyDenied) {
    //   handler.openAppSettings();
    // }
    // if (status.isGranted) {
    //   _statuses;
    // }
    // if (status.isRestricted) {
    //   handler.openAppSettings();
    // }
    // if(camStat.isDenied){
    //   handler.Permission.camera.request();
    // }
    // if(camStat.isPermanentlyDenied){
    //   handler.openAppSettings();
    // }
    // if(camStat.isRestricted){
    //   handler.openAppSettings();
    // }
    // if(storage.isDenied){
    //   handler.Permission.storage.request();
    // }
    // if(storage.isPermanentlyDenied){
    //   handler.openAppSettings();
    // }
    // if(storage.isRestricted){
    //   handler.openAppSettings();
    // }
    getPref(context);
    return _statuses;
  }
}
