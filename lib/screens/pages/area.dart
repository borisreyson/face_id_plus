import 'dart:io';

import 'package:face_id_plus/model/map_area.dart';
import 'package:face_id_plus/screens/pages/maps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class AreaAbp extends StatefulWidget {
  const AreaAbp({Key? key}) : super(key: key);

  @override
  _AreaAbpState createState() => _AreaAbpState();
}

class _AreaAbpState extends State<AreaAbp> {
  late final handler.Permission _permission = handler.Permission.location;
  late handler.PermissionStatus _permissionStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF21BFBD),
        elevation: 0,
          actions: <Widget>[
            IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const PointMaps()));
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
              List<MapAreModel> maps = snapshot.data!;
              return Column(
                  children: maps.map((e) => mapListWidget(e)).toList());
            }else{
              return const Center(child: CircularProgressIndicator());
            }
            default:
              return const Center(child: CircularProgressIndicator());
          }
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
              ElevatedButton(onPressed: (){
              }, child: const Text("Edit",style: TextStyle(fontSize: 10),))
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
}
