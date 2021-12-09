import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int isLogin = 0;

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    setState(() {
      getPref(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin")??0;
    if (isLogin == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Splash()));
    }
  }
}
