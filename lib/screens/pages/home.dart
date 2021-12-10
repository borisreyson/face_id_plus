import 'dart:async';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

String? _jam;
String? _menit;
String? _detik;
String? _tanggal;
String? nama, nik;
int? isLogin = 0;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    nama = "";
    nik = "";
    _jam = "07";
    _menit = "00";
    _detik = "00";
    setState(() {
      getPref(context);
      DateFormat fmt = DateFormat("dd MMMM yyyy");
      DateTime now = DateTime.now();
      _tanggal = "${fmt.format(now)}";
      Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    });
    super.initState();
  }

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin")!;
    if (isLogin == 1) {
      nama = sharedPref.getString("nama");
      nik = sharedPref.getString("nik");
    } else {
      nama = "";
      nik = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: Column(
        children: <Widget>[
          _header(),
          _headerContent(),
          _contents(),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0,top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 100.0,
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
      ),
    );
  }

  Widget _headerContent() {
    return Container(
      height: MediaQuery.of(context).size.height/5,
      child: Column(
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
            children: [
              Padding(
                padding: EdgeInsets.only(left: 40.0),
                child: Text(
                  "${nama}",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 15.0),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 60.0),
                child: Text(
                  "${nik}",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 15.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contents() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color(0xFFF2E638),
        borderRadius: BorderRadius.all(Radius.circular(75.0)),
      ),
      child: _jamWidget()
      
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
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
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
        ),
        
      ],
    );
  }

  Widget _btnAbsen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0)),
          ),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 2.5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green
                        ),
                        child:  Text("Masuk",style: TextStyle(color: Colors.white),),
                          
                          onPressed: () {  },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text("Pulang",style: TextStyle(color: Colors.white),),
                            onPressed: (){

                            },
                          ),
                    ),
                  ],
                ),
              ),
            _listAbsen()
            ],
          ),
        ),
      ],
    );
  }
  Widget _listAbsen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(topRight: Radius.circular(20.0)),
      ),
      child: ListView(
        primary: false,
        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
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
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
                  SizedBox(
                    height: 300.0,
                    child: Text("Boris"),
                  ),
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
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('This is a demo alert dialog.'),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('Would you like to approve of this message?'),
                    SizedBox(
                      height: 10.0,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text("Keluar"),
                    ),
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
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        );
      },
    );
  }
}
