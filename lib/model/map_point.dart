import 'package:http/http.dart' as http;
import 'dart:convert';
class MapPoint{
  bool success;
  MapPoint({required this.success});

  static Future<bool> saveMapPoint(String lat,String lng) async{
    String apiUrl = "https://lp.abpjobsite.com/api/area/save/point";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"lat": lat, "lng": lng});
    var jsonObject = json.decode(apiResult.body);
    return (jsonObject['success'])?jsonObject['success']:false;
  }
  static Future<bool> delMapPoint(String idLok) async{
    String apiUrl = "https://lp.abpjobsite.com/api/area/del/point";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"idLok": idLok});
    var jsonObject = json.decode(apiResult.body);
    return (jsonObject['success'])?jsonObject['success']:false;
  }
  static Future<bool> editMapPoint(String idLok,String lat,String lng) async{
    String apiUrl = "https://lp.abpjobsite.com/api/area/edit/point";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"idLok": idLok,"lat": lat, "lng": lng});
    var jsonObject = json.decode(apiResult.body);
    return (jsonObject['success'])?jsonObject['success']:false;
  }

}