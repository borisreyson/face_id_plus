import 'dart:async';
import 'dart:io' show Platform;
import 'package:face_id_plus/model/last_absen.dart';
import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/screens/pages/absen_masuk.dart';
import 'package:face_id_plus/screens/pages/absen_pulang.dart';
import 'package:face_id_plus/screens/pages/masuk.dart';
import 'package:face_id_plus/screens/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as iosLocation;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  iosLocation.Location locationIOS = iosLocation.Location();
  late final handler.Permission _permission = handler.Permission.location;
  late handler.PermissionStatus _permissionStatus;
  String? _jam;
  String? _menit;
  String? _detik;
  String? _tanggal;
  String? nama, nik;
  int? isLogin = 0;
  double _masuk = 0.0;
  double _pulang = 0.0;
  double _diluarAbp = 0.0;
  bool outside = true;
  late Position currentPosition;
  LatLng? myLocation;
  bool iosMapLocation = false;
  var geoLocator = Geolocator();
  Position? position;
  final _map_controller = Completer();
  late GoogleMapController _googleMapController;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(-0.5634222, 117.0139606), zoom: 14.4746);
  Future<void> locatePosition() async {
    // if (Platform.isAndroid) {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position!;
    myLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
    // }
    print("locationIOS1 : ${myLocation}");
    if (myLocation != null) {
      if (!iosMapLocation) {
        iosMapLocation = true;
      }
      CameraPosition cameraPosition =
          CameraPosition(target: myLocation!, zoom: 20.4756);
      return await _googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      _requestLocation();
    }
    nama = "";
    nik = "";
    _jam = "";
    _menit = "";
    _detik = "";
    setState(() {
      getPref(context);
      DateFormat fmt = DateFormat("dd MMMM yyyy");
      DateTime now = DateTime.now();
      _tanggal = fmt.format(now);
      Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _mainContent();
  }

  Widget _mainContent() {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const Profile()));
            },
            icon: const Icon(Icons.menu),
            color: Colors.white,
          ),
        ],
        backgroundColor: const Color(0xFF21BFBD),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: <Widget>[
          (Platform.isAndroid) ? _headerContent() : _headerIos(),
          const SizedBox(height: 8),
          Expanded(
            child: IntrinsicHeight(child: _futureBuilder()),
          ),
        ],
      ),
    );
  }

  Widget _futureBuilder() {
    return FutureBuilder<List<MapAreModel>>(
      future: _loadArea(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          List<LatLng> pointAbp = [];
          List<MapAreModel> data = snapshot.data;
          List<Polygon> _polygons = [];
          for (var p in data) {
            pointAbp.add(LatLng(p.lat!, p.lng!));
          }
          _polygons.add(Polygon(
              polygonId: const PolygonId("ABP"),
              points: pointAbp,
              strokeWidth: 2,
              strokeColor: Colors.red,
              fillColor: Colors.white.withOpacity(0.3)));
          if (myLocation != null) {
            bool _insideAbp = _checkIfValidMarker(myLocation!, pointAbp);
            if (_insideAbp) {
              _diluarAbp = 0.0;
              outside = true;
            } else {
              outside = false;
              _diluarAbp = 1.0;
            }
          }

          if (Platform.isAndroid) {
            if (_permissionStatus.isGranted) {
              locatePosition();
              return _loadMaps(_polygons);
            } else {
              _requestLocation();
              return const Center(child: CircularProgressIndicator());
            }
          } else if (Platform.isIOS) {
            if (myLocation == null) {
              iosGetLocation();
              if (iosMapLocation) {
                locatePosition();
                return _loadMaps(_polygons);
              } else {
                locatePosition();
              }
            } else {
              locatePosition();
              return _loadMaps(_polygons);
            }
          }
          return const Center(child: CircularProgressIndicator());
        } else {
          _loadArea();
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> iosGetLocation() async {
    iosLocation.LocationData _locationData = await locationIOS.getLocation();
    myLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    setState(() {
      if (myLocation != null) {
        iosMapLocation = true;
      } else {
        iosMapLocation = false;
      }
    });
    return;
  }

  Widget _loadMaps(List<Polygon> _shape) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.hybrid,
      onMapCreated: (GoogleMapController controller) {
        _map_controller.complete(controller);
        _googleMapController = controller;
      },
      polygons: Set<Polygon>.of(_shape),
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  Widget _headerContent() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.only(bottom: 55),
          color: const Color(0xFF21BFBD),
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
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      "$nama",
                      style: const TextStyle(
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
                    padding: const EdgeInsets.only(left: 60.0),
                    child: Text(
                      "$nik",
                      style: const TextStyle(
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
      ]),
    );
  }

  Widget _headerIos() {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.only(bottom: 55),
        color: const Color(0xFF21BFBD),
        child: Column(
          children: <Widget>[
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Selamat Datang,",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "$nama",
                    style: const TextStyle(
                        fontFamily: 'Montserrat', color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Text(
                    "$nik",
                    style: const TextStyle(
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
    ]);
  }

  Widget _contents() {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
      color: const Color(0xFFF2E638),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            (Platform.isAndroid) ? _jamWidget() : _jamIos(),
            (outside) ? _btnAbsen() : diluarArea()
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
            "$_tanggal",
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _jamIos() {
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
                    fontSize: 20.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Text(
                "$_menit",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              const Text(
                ":",
                style: TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Text(
                "$_detik",
                style: const TextStyle(
                    color: Color(0xFF8C6A03),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ],
          ),
        ),
        Center(
          child: Text(
            "$_tanggal",
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _btnAbsen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Opacity(
            opacity: _masuk,
            child: Padding(
              padding: const EdgeInsets.only(right: 2.5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: const Text(
                  "Masuk",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const AbsenMasuk()));
                },
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
                child: const Text(
                  "Pulang",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const AbsenPulang()));
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
        Expanded(
            child: Opacity(
                opacity: _diluarAbp,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(
                          child: Column(
                        children: const [
                          Text(
                            "Anda Diluar Area",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            "PT Alamjaya Bara Pratama",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ))),
                )))
      ],
    );
  }

  void _getTime() {
    setState(() {
      _jam = "${DateTime.now().hour}".padLeft(2, "0");
      _menit = "${DateTime.now().minute}".padLeft(2, "0");
      _detik = "${DateTime.now().second}".padLeft(2, "0");
    });
  }

  Future<List<MapAreModel>> _loadArea() async {
    _permissionStatus = await _permission.status;

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

  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin")!;
    setState(() {
      if (isLogin == 1) {
        nama = sharedPref.getString("nama");
        nik = sharedPref.getString("nik");
        loadLastAbsen(nik!);
      } else {
        nama = "";
        nik = "";
      }
    });
  }

  _requestLocation() async {
    var status = await _permission.status;
    if (status.isDenied) {
      await handler.Permission.locationAlways.request();
    }
    if (status.isPermanentlyDenied) {
      handler.openAppSettings();
    }
    if (status.isGranted) {
      locatePosition();
    }
    if (status.isRestricted) {
      handler.openAppSettings();
    }
    Map<handler.Permission, handler.PermissionStatus> _statuses = await [
      handler.Permission.location,
      handler.Permission.locationAlways,
      handler.Permission.locationWhenInUse
    ].request();
    return _statuses;
  }

  loadLastAbsen(String _nik) async {
    var lastAbsen = await LastAbsen.apiAbsenTigaHari(_nik);
    if (lastAbsen != null) {
      if (lastAbsen.lastAbsen != null) {
        var absenTerakhir = lastAbsen.lastAbsen;
        print("LastAbsen : ${lastAbsen.lastAbsen}");
        setState(() {
          if (absenTerakhir == "Masuk") {
            _masuk = 0.0;
            _pulang = 1.0;
          } else if (absenTerakhir == "Pulang") {
            _masuk = 1.0;
            _pulang = 0.0;
          }
        });
      }
    }
  }
}
