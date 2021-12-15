import 'dart:async';
import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/services/location_service.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _jam;
  String? _menit;
  String? _detik;
  String? _tanggal;
  String? nama, nik;
  int? isLogin = 0;
  late Position currentPosition;
  var geoLocator = Geolocator();
  // late final Permission _permission = Permission.location;
  MapAreModel? _area;
  Completer<GoogleMapController> _map_controller = Completer();
  late GoogleMapController _googleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(target: LatLng(-0.5634222, 117.0139606),zoom: 14.4746);
  Future<void> locatePosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition,zoom:14.4756);
    print("New Location");
    return await _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    // _permissionForStatus();
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
      _loadAreaMaps();
    });

    super.initState();
  }
  // _permissionForStatus() async{
  //   final status = await _permission.status;
  //   if(status.isDenied){
  //     _permissionForStatus();
  //   }
  //   if(await Permission.location.isRestricted){
  //     openAppSettings();
  //   }
  //   if(await Permission.location.isGranted){
  //     print("$status");
  //     locatePosition();
  //   }
  //   if(await Permission.location.isPermanentlyDenied){
  //     _permissionForStatus();
  //    }
  //   await [Permission.location,Permission.locationWhenInUse].request();
  // }
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
    UserLocation userLocation = Provider.of<UserLocation>(context);
    print("UserLocation Lat: ${userLocation.latitude} | Lng : ${userLocation.longitude}");
    return _mainContent();
  }
  Widget _mainContent(){
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showMyDialog();
            },
            icon: Icon(Icons.menu),
            color: Colors.white,
          ),
        ],
        backgroundColor: Color(0xFF21BFBD),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: <Widget>[
          _headerContent(),
          SizedBox(height: 10),
          Expanded(
            child: IntrinsicHeight(
              child: FutureBuilder(
                future: locatePosition(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                  return GoogleMap(initialCameraPosition: _kGooglePlex,
                    mapType: MapType.hybrid,
                    onMapCreated: (GoogleMapController controller){
                      _map_controller.complete(controller);
                      _googleMapController = controller;
                      locatePosition();
                    },
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _headerContent() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 55),
            color: Color(0xFF21BFBD),
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
          ),
          _contents(),
        ]
      ),
    );
  }

  Widget _contents() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only(top:60,left: 20,right: 20),
      color: Color(0xFFF2E638),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _jamWidget(),
            _btnAbsen()
          ],
        ),
      ),
    );
  }

  Widget _jamWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        Center(
          child: Text(
            "${_tanggal}",
            style:
            TextStyle(color: Colors.black87),
          ),
        ),

      ],
    );
  }

  Widget _btnAbsen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 2.5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green
              ),
              child:  Text("Masuk",style: TextStyle(color: Colors.white),),

                onPressed: () {  },
                  ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
            child: Text("Pulang",style: TextStyle(color: Colors.white),),
                  onPressed: (){

                  },
                ),
          ),
        ),
      ],
    );
  }
  Widget _listAbsen() {
    return IntrinsicHeight(
      child: ListView(
        primary: false,
        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: SizedBox(
              child: ListView(
                children: const <Widget>[
                  SizedBox(
                    height: 300.0,
                    child: Text("Bor3is"),
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
  _loadAreaMaps() async{
    var map = await MapAreModel.mapAreaApi("0").then((value) {
      _area = value;
      print("${_area!.lat}");
    });
  }
}
