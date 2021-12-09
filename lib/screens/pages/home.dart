import 'dart:async';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String? _jam;
String? _menit;
String? _detik;
String? _tanggal;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _jam = "07";
    _menit = "00";
    _detik = "00";
    setState(() {
      DateFormat fmt = DateFormat("dd MMMM yyyy");
      DateTime now = DateTime.now();
      _tanggal = "${fmt.format(now)}";
      Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: ListView(
        children: <Widget>[
          _header(),
          const SizedBox(
            height: 0.0,
          ),
          _headerContent(),
          _contents()
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 125.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _showMyDialog();
                  },
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _headerContent() {
    return Column(
      children: <Widget>[
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "Selamat Datang,",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 50.0),
              child: Text(
                "Boris Reyson Sitorus",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 15.0),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  Widget _contents() {
    return Container(
      height: MediaQuery.of(context).size.height - 125,
      decoration: const BoxDecoration(
        color: Color(0xFFF2E638),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
      ),
      child: ListView(
        primary: false,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: _jamWidget()),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _listAbsen(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _jamWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Text(
            "${_tanggal}",
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "$_jam",
              style: const TextStyle(
                  color: Color(0xFF8C6A03),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            const Text(
              ":",
              style: TextStyle(
                  color: Color(0xFF8C6A03),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            Text(
              "$_menit",
              style: const TextStyle(
                  color: Color(0xFF8C6A03),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            const Text(
              ":",
              style: TextStyle(
                  color: Color(0xFF8C6A03),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            Text(
              "$_detik",
              style: const TextStyle(
                  color: Color(0xFF8C6A03),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _listAbsen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
      ),
      child: ListView(
        primary: false,
        padding: const EdgeInsets.only(left: 25.0, right: 20.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: const <Widget>[
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _logOut() async {
    var _pref = await SharedPreferences.getInstance();
    var isLogin = _pref.getInt("isLogin");
    if (isLogin == 1) {
      _pref.setInt("isLogin", 0);
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Splash()));
      });
    } else {}
  }

  void _getTime() {
    setState(() {
      _jam = "${DateTime.now().hour}".padLeft(2, "0");
      _menit = "${DateTime.now().minute}".padLeft(2, "0");
      _detik = "${DateTime.now().second}".padLeft(2, "0");
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('This is a demo alert dialog.'),
                  Text('Would you like to approve of this message?'),
                  InkWell(
                    onTap: () {
                      Navigator.maybePop(context);
                    },
                    child: Text("Tutup"),
                  )
                ],
              ),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
  }
}
