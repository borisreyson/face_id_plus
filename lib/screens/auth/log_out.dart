
import 'package:face_id_plus/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
int? isLogin;

class LogOut extends StatefulWidget {
  const LogOut({Key? key}) : super(key: key);

  @override
  _LogOutState createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  @override
  void initState() {
    getPref(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Row(
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  logOut(context, 0);
                },
                child: Text("Log Out"))
          ],
        ),
      ),
    );
  }

  getPref(BuildContext context) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    isLogin = _pref.getInt("isLogin");
    if (isLogin == 0) {
      Navigator.maybePop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context)=>FormLogin()));
    }
  }

  logOut(BuildContext context, int value) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setInt("isLogin", value);
    isLogin = value;
    setState(() {
      getPref(context);
    });
  }
}
