import 'dart:convert';

import 'package:face_id_plus/model/last_absen.dart';
import 'package:http/http.dart' as http;

class AbsenList {
  ListAbsen? listAbsen;
  AbsenList({this.listAbsen});
  factory AbsenList.fromJson(Map<String, dynamic> object) {
    return AbsenList(listAbsen: ListAbsen.fromJason(object['listAbsen']));
  }
  static Future<AbsenList> apiAbsenTigaHari(String _nik, String _status) async {
    String apiUrl =
        "https://abpjobsite.com/api/android/get/list/absen?nik=$_nik&status=$_status";
    var apiResult = await http.get(Uri.parse(apiUrl));
    var jsonObject = json.decode(apiResult.body);
    var absenList = AbsenList.fromJson(jsonObject);
    return absenList;
  }
}

class ListAbsen {
  int? currentPage;
  List<Presensi>? data;
  int? from;
  int? lastPage;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;
  ListAbsen(
      {this.currentPage,
      this.data,
      this.from,
      this.lastPage,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});
  factory ListAbsen.fromJason(Map<String, dynamic> object) {
    return ListAbsen(
      currentPage: object['current_page'],
      data: (object['data'] as List).map((e) => Presensi.fromJson(e)).toList(),
      from: object['from'],
      lastPage: object['last_page'],
      nextPageUrl: object['next_page_url'],
      path: object['path'],
      perPage: object['per_page'],
      prevPageUrl: object['prev_page_url'],
      to: object['to'],
      total: object['total'],
    );
  }
}
