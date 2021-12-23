import 'package:face_id_plus/model/last_absen.dart';
import 'package:face_id_plus/model/list_absen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LihatAbsen extends StatefulWidget {
  const LihatAbsen({Key? key}) : super(key: key);
  @override
  _LihatAbsenState createState() => _LihatAbsenState();
}

class _LihatAbsenState extends State<LihatAbsen> {
  Widget loader = const Center(child: CircularProgressIndicator());
  int _selectedNavbar = 0;
  String apiStatus = "Masuk";
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: content(),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  AppBar appBar() {
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
        "Absensi",
        style: TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        Visibility(
          visible: false,
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              splashColor: Colors.black,
              child: const Icon(
                Icons.calendar_today,
                color: Colors.black,
              ),
              onTap: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(2018, 1, 1),
                    maxTime: DateTime.now(), onChanged: (date) {
                  print("Change Date: $date");
                }, onConfirm: (date) {
                  print("Confirm Date : $date");
                }, currentTime: DateTime.now());
              },
            ),
          ),
        )
      ],
    );
  }

  Widget content() {
    return Container(
        color: Colors.white,
        height: double.maxFinite,
        child: ListView(
          controller: _scrollController,
          shrinkWrap: true,
          children: [
            topContent(),
            bottomContent(),
          ],
        ));
  }

  Widget topContent() {
    return Visibility(
      visible: false,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Tanggal"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3.9,
                  child: ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Text("Submit"),
                    ),
                    onPressed: () {
                      lihatAbsenAPI(apiStatus);
                      _scrollController.animateTo(
                        0.0,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomContent() {
    return FutureBuilder(
        future: lihatAbsenAPI(apiStatus),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loader;
            case ConnectionState.done:
            AbsenList _absensi = snapshot.data;
            if (_absensi.listAbsen != null) {
              ListAbsen _presensi = _absensi.listAbsen!;
              List<Presensi> absensiList = _presensi.data!;
              return Column(
                  children: absensiList.map((e) => absensiWidget(e)).toList());
            }
            return loader;
            default:
            return loader;
          }
        });
  }

  Widget absensiWidget(Presensi _absen) {
    DateFormat fmt = DateFormat("dd MMMM yyyy");
    var tgl = DateTime.parse("${_absen.tanggal}");
    TextStyle _style = const TextStyle(fontSize: 12, color: Colors.white);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
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
                // Text(nama, style: _style),
                Text("${_absen.status}", style: _style),
                Text(fmt.format(tgl), style: _style),
                Text("${_absen.jam}", style: _style),
                Text("${_absen.nik}", style: _style),
                Text("${_absen.lupaAbsen}", style: _style),
              ],
            )
          ],
        ),
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

  void _changeSelectedNavBar(int index) {
    setState(() {
      _selectedNavbar = index;
      if (index == 0) {
        apiStatus = "Masuk";
      } else if (index == 1) {
        apiStatus = "Pulang";
      }
    });
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  BottomNavigationBar bottomNavigation() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_downward,
              color: Colors.black,
            ),
            label: "Masuk",
            activeIcon: Icon(
              Icons.arrow_downward,
              color: Colors.white,
            ),
            backgroundColor: Colors.green),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_upward,
              color: Colors.black,
            ),
            label: "Pulang",
            backgroundColor: Colors.red,
            activeIcon: Icon(
              Icons.arrow_upward,
              color: Colors.white,
            )),
      ],
      currentIndex: _selectedNavbar,
      onTap: _changeSelectedNavBar,
      type: BottomNavigationBarType.shifting,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  Future<AbsenList> lihatAbsenAPI(String status) async {
    var pref = await SharedPreferences.getInstance();
    var nik = pref.getString("nik");
    if (nik == null) {}
    AbsenList listAbsen = await AbsenList.apiAbsenTigaHari(nik!, status);
    return listAbsen;
  }
}
