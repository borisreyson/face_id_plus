import 'package:face_id_plus/model/face_login_model.dart';
import 'package:face_id_plus/model/tigahariabsen.dart';
import 'package:face_id_plus/screens/pages/lihat_absensi.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_absen.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String nama;
  late String nik;
  late int _showAbsen;
  Widget loader = const Center(child: CircularProgressIndicator());
  @override
  void initState() {
    _getPref();
    nik = "";
    _showAbsen = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _header(),
        body: Container(
            color: const Color(0xf0D9D9D9),
            height: double.maxFinite,
            child: _topContent()));
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
      title: const Text(
        "Profile",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _topContent() {
    return FutureBuilder(
        future: _getPref(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              Datalogin fUsers = Datalogin();
              fUsers = snapshot.data;
              nik = fUsers.nik!;
              _showAbsen = fUsers.showAbsen!;
              return Stack(
                children: [
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView(
                            children: [
                              Card(
                                color: const Color.fromRGBO(129, 47, 51, 51),
                                elevation: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          "${fUsers.nama}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "${fUsers.nik}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Text("${fUsers.devisi}",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: SingleChildScrollView(child: _content()),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _bottomContent()
                ],
              );
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }

  Widget _content() {
    return FutureBuilder(
        future: _loadTigaHari(nik),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              List<AbsenTigaHariModel> _absensi = snapshot.data;
              print("NIK $nik");
              if (_absensi.isNotEmpty) {
                return Column(
                    children: _absensi.map((ab) => _cardAbsen(ab)).toList());
              }
              return loader;
            case ConnectionState.waiting:
              return loader;
            default:
              return loader;
          }
        });
  }

  Widget _cardAbsen(AbsenTigaHariModel _absen) {
    DateFormat fmt = DateFormat("dd MMMM yyyy");
    var tgl = DateTime.parse("${_absen.tanggal}");
    TextStyle _style = const TextStyle(fontSize: 12, color: Colors.white);
    return Card(
      elevation: 10,
      shadowColor: Colors.black87,
      color: (_absen.status == "Masuk") ? Colors.green : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imageResolve(_absen.gambar!),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama, style: _style),
              Text("${_absen.status}", style: _style),
              Text(fmt.format(tgl), style: _style),
              Text("${_absen.jam}", style: _style),
              Text("${_absen.nik}", style: _style),
              Text("${_absen.lupa_absen}", style: _style),
            ],
          )
        ],
      ),
    );
  }

  Widget imageResolve(String gambar) {
    NetworkImage image = NetworkImage(gambar);
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
          image: DecorationImage(
            image: image,
            fit: BoxFit.fitWidth,
          ),
          color: Colors.white),
    );
  }

  Widget _bottomContent() {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LihatAbsen()));
                  },
                  child: const Text("Lihat Absen")),
              Visibility(
                visible: (_showAbsen == 1) ? true : false,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminListAbsen()));
                    },
                    child: const Text("AdminAbsen")),
              ),
              ElevatedButton(
                  onPressed: () {
                    _askLogout();
                  },
                  child: const Text("Log Out")),
            ],
          ),
        ));
  }

  Future<Datalogin> _getPref() async {
    Datalogin _users = Datalogin();
    SharedPreferences _pref = await SharedPreferences.getInstance();
    nama = _pref.getString("nama").toString();
    String nik = _pref.getString("nik").toString();
    String devisi = _pref.getString("devisi").toString();
    int? _showAbsen = _pref.getInt("show_absen");
    _users.nama = nama;
    _users.nik = nik;
    _users.devisi = devisi;
    print("showAbsen $_showAbsen");

    _users.showAbsen = (_showAbsen==null)?0:_showAbsen;

    return _users;
  }

  void _askLogout() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Apakah Anda Ingin Keluar?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _doLogOut();
                },
                child: const Text('Ya, Keluar!'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  child: const Text('Tidak')),
            ],
          );
        });
  }

  _doLogOut() async {
    var _pref = await SharedPreferences.getInstance();
    var isLogin = _pref.getInt("isLogin");
    if (isLogin == 1) {
      await _pref.clear();
      Navigator.maybePop(context);
      Navigator.maybePop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const Splash()),
          (context) => false);
    }
  }

  Future<List<AbsenTigaHariModel>> _loadTigaHari(String nik) async {
    var absensi = await AbsenTigaHariModel.apiAbsenTigaHari(nik);
    return absensi;
  }
}
