import 'dart:async';
import 'dart:typed_data';

import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/model/map_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as iosLocation;
import 'package:permission_handler/permission_handler.dart' as handler;
import 'dart:ui' as ui;
import 'dart:io' show Platform;

class PointMaps extends StatefulWidget {
  final int btnAdd;
  final int? idLok;
  final LatLng? savedLok;
  const PointMaps(int this.btnAdd,this.idLok,this.savedLok, {Key? key}) : super(key: key);
  @override
  _PointMapsState createState() => _PointMapsState();
}
class _PointMapsState extends State<PointMaps> {
  iosLocation.Location locationIOS = iosLocation.Location();
  late final handler.Permission _permission = handler.Permission.location;
  late handler.PermissionStatus _permissionStatus;
  bool isBusy = false;
  bool outside = true;
  late Position currentPosition;
  LatLng? myLocation;
  bool iosMapLocation = false;
  var geoLocator = Geolocator();
  Position? position;
  final _map_controller = Completer();
  late GoogleMapController _googleMapController;
  late BitmapDescriptor customIcon;
  late Set<Marker> markers = {};
  late Marker marker;
  bool lokasiPalsu = false;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(-0.5634222, 117.0139606), zoom: 14.2746);
  Future<void> locatePosition() async {
    // if (Platform.isAndroid) {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position!;
    myLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
    // }
    lokasiPalsu = position!.isMocked;
    setState(() {
      print("Android Lokasi ${myLocation}");
    });
    if (myLocation != null) {
      if (!iosMapLocation) {
        iosMapLocation = true;
      }
      CameraPosition cameraPosition =
          CameraPosition(target: myLocation!, zoom: 19.3756);
      return await _googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }else{
      locatePosition();
    }
  }

  @override
  void initState() {
    setCustomMapPin();
    if (Platform.isAndroid) {
      _requestLocation();
    }
    if (lokasiPalsu == true) {
      appClose();
    }
    super.initState();
  }
  Widget appClose() {
    return AlertDialog(
      title: const Text('Lokasi'),
      content: const Text('Aplikasi Fake Gps / Lokasi Palsu Terdetek!'),
      actions: <Widget>[
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
void setCustomMapPin() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/abp_60x60.png', 60);
    customIcon = await BitmapDescriptor.fromBytes(markerIcon);
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF21BFBD),
          elevation: 0
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        body: Column(children:<Widget>[
          Expanded(child: IntrinsicHeight(child: _futureBuilder())),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    (widget.btnAdd==1)?Text("ID LOK : ${widget.idLok}"):Container(),
                    (widget.btnAdd==1)?Text("OLD LAT : ${widget.savedLok?.latitude}"):Container(),
                    (widget.btnAdd==1)?Text("OLD LNG : ${widget.savedLok?.longitude}"):Container(),
                    Text("NEW LAT : ${myLocation?.latitude}"),
                    Text("NEW LNG : ${myLocation?.longitude}"),
                  ],
                ),
                (widget.btnAdd==0)?
                ElevatedButton(onPressed: (){
                  MapPoint.saveMapPoint("${myLocation?.latitude}", "${myLocation?.longitude}").then((value) =>updateUI(value));
                }
                    , child: const Text("Simpan",style: TextStyle(fontSize: 10),)):
                ElevatedButton(onPressed: (){
                  MapPoint.editMapPoint("${widget?.idLok}","${myLocation?.latitude}", "${myLocation?.longitude}").then((value) => {
                  if(value){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,
                      content: Text("Berhasil!",style: TextStyle(color: Colors.white),)))
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red,
                    content: Text("Gagal , Coba Lagi!",style: TextStyle(color: Colors.white),)))
                    }
                  });
                },
                    style: ElevatedButton.styleFrom(primary: Colors.green)
                    , child: const Text("Update",style: TextStyle(fontSize: 10),)),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                },
                    style: ElevatedButton.styleFrom(primary: Colors.redAccent)
                    , child: const Text("Batal",style: TextStyle(fontSize: 10),)),

              ],
            ),
          )
          ]));
  }

  Future<void> iosGetLocation() async {
    iosLocation.LocationData _locationData = await locationIOS.getLocation();
    myLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    if (myLocation != null) {
      iosMapLocation = true;
    } else {
      iosMapLocation = false;
    }
    setState(() {
      print("IOS Lokasi ${myLocation}");

    });
    return;
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

          if (Platform.isAndroid) {
            if (_permissionStatus.isGranted) {
              locatePosition();
              return _loadMaps(_polygons, pointAbp);
            } else {
              _requestLocation();
              return const Center(child: CircularProgressIndicator());
            }
          } else if (Platform.isIOS) {
            if (myLocation == null) {
              iosGetLocation();
              if (iosMapLocation) {
                locatePosition();
                return _loadMaps(_polygons, pointAbp);
              } else {
                locatePosition();
              }
            } else {
              locatePosition();
              return _loadMaps(_polygons, pointAbp);
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

  Future<List<MapAreModel>> _loadArea() async {
    outside = true;
    _permissionStatus = await _permission.status;
    var area = await MapAreModel.mapAreaApi("0");
    return area;
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
  Widget _loadMaps(List<Polygon> _shape, List<LatLng> pointAbp) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _map_controller.complete(controller);
        _googleMapController = controller;
        setState(() {
          marker = Marker(
            markerId: const MarkerId('abpenergy'),
            position: const LatLng(-0.5634222, 117.0139606),
            icon: customIcon,
            infoWindow: const InfoWindow(
              title: 'PT Alamjaya Bara Pratama',
            ),
          );
          markers.add(marker);
        });
      },
      polygons: Set<Polygon>.of(_shape),
      markers: markers,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  updateUI(bool value){
    if(value){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,
          content: Text("Berhasil!",style: TextStyle(color: Colors.white),)));
      Navigator.pop(context,"berhasil");
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red,
          content: Text("Gagal , Coba Lagi!",style: TextStyle(color: Colors.white),)));
    }
  }

}
