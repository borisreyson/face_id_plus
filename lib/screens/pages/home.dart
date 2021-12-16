import 'dart:async';
import 'dart:collection';
import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/screens/pages/profile.dart';
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
  double _masuk=1.0;
  double _pulang=1.0;
  double _diluarAbp = 0.0;
  bool outside = true;
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
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition,zoom:20.4756);
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
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>Profile()));
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
              child: FutureBuilder<List<MapAreModel>>(
                future: _loadArea(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                  locatePosition();
                if(snapshot.hasData){
                    List<LatLng> pointAbp = [];
                    List<MapAreModel> data = snapshot.data;
                    List<Polygon> _polygons = [];
                    data.forEach((p) {
                      pointAbp.add(LatLng(p.lat!, p.lng!));
                    });
                    _polygons.add(Polygon(polygonId: PolygonId("ABP"),points: pointAbp,strokeWidth: 2,strokeColor: Colors.red,fillColor: Colors.white.withOpacity(0.3)));
                    print("areaMaps 1 ${_polygons}");
                    LatLng myLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
                    bool _insideAbp = _checkIfValidMarker(myLocation,pointAbp);
                    if(_insideAbp){
                      // _diluarAbp=0.0;
                      // _masuk =1.0;
                      // _pulang =1.0;
                      // outside=true;
                    }else{
                      // outside=false;
                      // _diluarAbp=1.0;
                      // _masuk =0.0;
                      // _pulang =0.0;
                    }
                    print("InsideAbp ${_insideAbp}");
                    return _loadMaps(_polygons);
                  }else{
                    print("areaMaps 2");
                    _loadArea();
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _loadMaps(List<Polygon> _shape){
    return GoogleMap(initialCameraPosition: _kGooglePlex,
      mapType: MapType.hybrid,
      onMapCreated: (GoogleMapController controller){
        _map_controller.complete(controller);
        _googleMapController = controller;
        locatePosition();
      },
      polygons: Set<Polygon>.of(_shape),
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }
  Future<List<MapAreModel>> _loadArea() async{
    var area = await MapAreModel.mapAreaApi("0");
    return area;
  }
  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }
  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
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
            (outside)?_btnAbsen():diluarArea()
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
          child: Opacity(
            opacity: _masuk,
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
        ),
        Expanded(
          child: Opacity(
            opacity: _pulang,
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
        )
      ],
    );
  }
  Widget diluarArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Opacity(
            opacity: _diluarAbp,
            child: Container(
              margin: EdgeInsets.only(top: 20),
              color: Colors.white,
              child: Padding(padding: const EdgeInsets.all(10),
                  child: Center(child: Text("Anda Diluar Area PT Alamjaya Bara Pratama",style: TextStyle(color: Colors.red),))),
            )
        ))
      ],
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

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("Ya, Keluar"),
      onPressed: () { },
    );

    // set up the button
    Widget noButton = TextButton(
      child: Text("Batal"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,noButton
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
