import 'package:face_id_plus/model/face_login_model.dart';
import 'package:face_id_plus/model/tigahariabsen.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String nama;
  late String nik;
  @override
  void initState() {
    nik = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _header(),
        body: Container(
          color: const Color(0xf0D9D9D9),
          height: double.maxFinite,
          child: Stack(
            children: [_coverContent(), _bottomContent()],
          ),
        ));
  }

  AppBar _header() {
    return AppBar(
      backgroundColor: const Color(0xffffffff),
      elevation: 0,
      leading: InkWell(
        splashColor: const Color(0xff000000),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xff000000),
        ),
        onTap: () {
          Navigator.maybePop(context);
        },
      ),
      title: Text(
        "Profile",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _coverContent() {
    return Positioned(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: _topContent(),
      ),
    ));
  }

  Widget _topContent() {
    return FutureBuilder(
        future: _getPref(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            FaceLoginModel fUsers = FaceLoginModel();
            fUsers = snapshot.data;
            nik = fUsers.nik!;
            return RefreshIndicator(
              onRefresh: () async {
                await _getPref();
              },
              child: ListView(
                children: [
                  Card(
                    color: Color.fromRGBO(129, 47, 51, 51),
                    elevation: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              "${fUsers.nama}",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              "${fUsers.nik}",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text("${fUsers.devisi}",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: SingleChildScrollView(child: _content()),
                  )
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _content() {
    return FutureBuilder(
        future: _loadTigaHari(nik),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List<AbsenTigaHariModel> _absensi = snapshot.data;
            print("NIK ${nik}");
            if (_absensi.length > 0) {
              return Column(
                  children: _absensi.map((ab) => _cardAbsen(ab)).toList());
            } else {
              _loadTigaHari(nik);
              return Center(child: CircularProgressIndicator());
            }
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _cardAbsen(AbsenTigaHariModel _absen) {
    DateFormat fmt = DateFormat("dd MMMM yyyy");
    var tgl = DateTime.parse("${_absen.tanggal}");
    bool imageDone = false;

    AssetImage imgBefore = AssetImage('assets/images/ic_abp.png');
    NetworkImage image = NetworkImage(_absen.gambar!);
    image
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, status) {
      setState(() {
        if (status) {
          imageDone = true;
        } else {
          imageDone = false;
        }
      });
    }));
    return Card(
      elevation: 10,
      shadowColor: Colors.black87,
      color: (_absen.status == "Masuk") ? Colors.green : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (imageDone)?
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: image,
                  fit: BoxFit.fitWidth,
                ),
                color: Colors.white),
          ):Container(
            width: 100,
            height: 100,
            child: Center(child: CircularProgressIndicator(),),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${nama}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              Text("${_absen.status}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              Text("${fmt.format(tgl)}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              Text("${_absen.jam}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              Text("${_absen.nik}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              Text("${_absen.lupa_absen}",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _bottomContent() {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () {}, child: Text("Lihat Absen")),
              ElevatedButton(
                  onPressed: () {
                    _askLogout();
                  },
                  child: Text("Log Out")),
            ],
          ),
        ));
  }

  Future<FaceLoginModel> _getPref() async {
    FaceLoginModel _users = FaceLoginModel();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    nama = _pref.getString("nama").toString();
    String nik = _pref.getString("nik").toString();
    String devisi = _pref.getString("devisi").toString();
    _users.nama = nama;
    _users.nik = nik;
    _users.devisi = devisi;
    return _users;
  }

  void _askLogout() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Log Out'),
            content: Text('Apakah Anda Ingin Keluar?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _doLogOut();
                },
                child: Text('Ya, Keluar!'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  child: Text('Tidak')),
            ],
          );
        });
  }

  _doLogOut() async {
    var _pref = await SharedPreferences.getInstance();
    var isLogin = _pref.getInt("isLogin");
    if (isLogin == 1) {
      _pref.setInt("isLogin", 0);
      setState(() {
        Navigator.maybePop(context);
        Navigator.maybePop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Splash()),
            (context) => false);
      });
    } else {}
  }

  Future<List<AbsenTigaHariModel>> _loadTigaHari(String nik) async {
    var absensi = await AbsenTigaHariModel.apiAbsenTigaHari(nik);
    return absensi;
  }
}
