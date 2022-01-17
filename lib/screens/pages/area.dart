import 'dart:io';

import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/model/map_point.dart';
import 'package:face_id_plus/screens/pages/maps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class AreaAbp extends StatefulWidget {
  const AreaAbp({Key? key}) : super(key: key);

  @override
  _AreaAbpState createState() => _AreaAbpState();
}

class _AreaAbpState extends State<AreaAbp> {
  late final handler.Permission _permission = handler.Permission.location;
  late handler.PermissionStatus _permissionStatus;
  bool _refresh=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF21BFBD),
        elevation: 0,
          actions: <Widget>[
            IconButton(
            onPressed: ()async {
              var newPoint = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const PointMaps(0,null,null)));
              print("newPoint ${newPoint}");
              if(newPoint == "berhasil"){
                setState(() {
                });
              }
            },
            icon: const Icon(Icons.add),
            color: Colors.white,
          ),
          ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: loadContent(),
    );
  }

  loadContent() {
    return FutureBuilder(
        future: _loadArea(),
        builder:
            (BuildContext context, AsyncSnapshot<List<MapAreModel>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
            if(snapshot.data!=null){
              _refresh=true;
              List<MapAreModel> maps = snapshot.data!;
              return RefreshIndicator(
                onRefresh: pullRefresh,
                child: (_refresh)?ListView(
                    children: maps.map((e) => mapListWidget(e)).toList()):Center(child: CircularProgressIndicator(),),
              );
            }else{
              return const Center(child: CircularProgressIndicator());
            }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<void> pullRefresh() async {
    await _loadArea();
    setState(() {
      _refresh=true;
    });
  }
  Widget mapListWidget(MapAreModel _map) {
    TextStyle _style = const TextStyle(fontSize: 12, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID LOK : ${_map.idLok}", style: _style),
                  Text("LAT : ${_map.lat}", style: _style),
                  Text("LAT : ${_map.lng}", style: _style),
                ],
              ),
              Column(
                children:<Widget> [
                  ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.orangeAccent), onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PointMaps(1,_map.idLok,LatLng(_map.lat!,_map.lng!))));
                  },
                      child: const Text("Edit",style: TextStyle(fontSize: 10),)),
                  ElevatedButton(style:ElevatedButton.styleFrom(primary: Colors.redAccent) , onPressed: (){
                    MapPoint.delMapPoint("${_map.idLok}").then((value) => updateUI(value));
                  },
                      child: const Text("Hapus",style: TextStyle(fontSize: 10),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<List<MapAreModel>> _loadArea() async {
    _permissionStatus = await _permission.status;
    var area = await MapAreModel.mapAreaApi("0");
    return area;
  }
  updateUI(bool value){
    if(value){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,
          content: Text("Berhasil!",style: TextStyle(color: Colors.white),)));
    }else{
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red,
    content: Text("Gagal , Coba Lagi!",style: TextStyle(color: Colors.white),)));
    }
    setState(() {

    });
  }
}
