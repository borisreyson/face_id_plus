import 'package:face_id_plus/model/last_absen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AllAbsen {
  int? currenPage;
  List<Presensi>? presensi;
  int? from;
  int? lastPage;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  AllAbsen(
      {this.currenPage,
      this.presensi,
      this.from,
      this.lastPage,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});
  factory AllAbsen.fromJson(Map<String, dynamic> object) {
    return AllAbsen(
      currenPage: object['current_page'],
      presensi: (object['data'] as List).map((e) => Presensi.fromJson(e)).toList(),
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
  static Future<AllAbsen> adminAbsenApi(String status,String tgl) async{
    String apiUrl =
        "https://abpjobsite.com/absen/list/all?status=$status&tanggal=$tgl";
    var apiResult = await http.get(Uri.parse(apiUrl));
    var jsonObject = json.decode(apiResult.body);
    var absenList = AllAbsen.fromJson(jsonObject);
    return absenList;
  }
}
