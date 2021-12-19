import 'package:face_id_plus/screens/auth/login.dart';
import 'package:face_id_plus/screens/auth/register.dart';
import 'package:face_id_plus/screens/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int isLogin = 0;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    getPref(context);
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return _main();
  }

  Widget _main() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Opacity(
          opacity: (isLogin == 1) ? 0.0 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffffffff), Color(0xffA6BF4B)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _logo(),
                const SizedBox(
                  height: 80,
                ),
                _title(),
                SizedBox(
                  height: 90,
                ),
                _submitButton(),
                const SizedBox(
                  height: 20,
                ),
                // _signUpButton(),
                const SizedBox(
                  height: 20,
                ),
                // _label()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
        child: Container(
          height: 100,
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: NetworkImage("https://abpjobsite.com/abp_prof.png"),
            fit: BoxFit.contain,
          )),
        ));
  }

  Widget _signUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const FormRegister()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Text(
          'Register now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      hoverColor: Colors.white60,
      onTap: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FormLogin()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: const Color(0xffdf8e33).withAlpha(100),
                  offset: const Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
        ),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Text(
        "ABSENSI",
        style: TextStyle(
            color: Color(0xFF003F63),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: "RaleWay"),
      ),
    );
  }

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    if (sharedPref.getInt("isLogin") != null) {
      isLogin = sharedPref.getInt("isLogin")!;
      if (isLogin == 1) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomePage()));
      }
    }
  }
}
