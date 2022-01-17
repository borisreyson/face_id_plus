import 'dart:io' show Platform;
import 'package:face_id_plus/model/all_absen.dart';
import 'package:face_id_plus/model/last_absen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminListAbsen extends StatefulWidget {
  const AdminListAbsen({Key? key}) : super(key: key);

  @override
  _AdminListAbsenState createState() => _AdminListAbsenState();
}

class _AdminListAbsenState extends State<AdminListAbsen> {
  Widget loader = const Center(child: CircularProgressIndicator());
  int _selectedNavbar = 0;
  bool futureUpdate = true;
  String apiStatus = "Masuk";
  String tanggal = DateTime.now().toString();
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
          visible: true,
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
                  setState(() {
                    DateFormat fmt = DateFormat("dd MMMM yyyy");
                    futureUpdate = true;
                    tanggal = fmt.format(date);
                  });
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
            const SizedBox(
              height: 10,
            ),
            (futureUpdate) ? bottomContent() : loader,
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
                      lihatAbsenAPI(apiStatus, tanggal);
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
        future: lihatAbsenAPI(apiStatus, tanggal),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loader;
            case ConnectionState.done:
              double itemHeight = 0;
              var size = MediaQuery.of(context).size;
              if (Platform.isAndroid) {
                itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
                
              } else if (Platform.isIOS) {
                itemHeight = (size.height - kToolbarHeight - 24) / 2.08;
              }
              /*24 is for notification bar on Android*/
              final double itemWidth = size.width / 2;
              AllAbsen _absensi = snapshot.data;
              if (_absensi != null) {
                List<Presensi> absensiList = _absensi.presensi!;
                return GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisSpacing: 2.5,
                    mainAxisSpacing: 2.5,
                    crossAxisCount: 2,
                    childAspectRatio: (itemWidth / itemHeight),
                    scrollDirection: Axis.vertical,
                    children:
                        absensiList.map((e) => absensiWidget(e)).toList());
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
    return Card(
      elevation: 10,
      shadowColor: Colors.black87,
      color: Colors.white,
      child: Column(
        children: [
          imageResolve(_absen.gambar!),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${_absen.status}",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: (_absen.status == "Masuk")
                              ? Colors.green
                              : Colors.red)),
                  Text(
                    fmt.format(tgl),
                  ),
                  Text(
                    "${_absen.jam}",
                  ),
                  Text(
                    "${_absen.nik}",
                  ),
                  Text("${_absen.lupaAbsen}")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget imageResolve(String gambar) {
    NetworkImage image = NetworkImage(gambar);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 160,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
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
      futureUpdate = true;
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

  Future<AllAbsen> lihatAbsenAPI(String status, String tanggal) async {
    AllAbsen listAbsen = await AllAbsen.adminAbsenApi(status, tanggal);
    return listAbsen;
  }
}
