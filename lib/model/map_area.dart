import 'package:http/http.dart' as http;
import 'dart:convert';

class MapAreModel {
  int? idLok;
  String? company;
  double? lat;
  double? lng;
  int? flag;
  String? timeUpdate;
  MapAreModel(
      {this.idLok,
        this.company,
        this.lat,
        this.lng,
        this.flag,
        this.timeUpdate});

  factory MapAreModel.fromJason(Map<String, dynamic> object) {
    return MapAreModel(
      idLok: object['idLok'],
      company: object['company'],
      lat: object['lat'],
      lng: object['lng'],
      flag: object['flag'],
      timeUpdate: object['time_update'],
    );
  }

  static Future<List<MapAreModel>> mapAreaApi(String _company) async {
    String apiUrl = "https://abpjobsite.com/absen/map/area?company="+_company;
    var apiResult = await http.get(Uri.parse(apiUrl));
    var jsonObject = json.decode(apiResult.body);
    return (jsonObject['mapArea'] as List).map((e) => MapAreModel.fromJason(e)).toList();
  }
}
