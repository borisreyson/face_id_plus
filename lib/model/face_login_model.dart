import 'package:http/http.dart' as http;
import 'dart:convert';

class FaceLoginModel {
  int? no;
  String? nik;
  String? nama;
  String? departemen;
  String? devisi;
  String? jabatan;
  int? flag;
  int? showAbsen;
  int? perusahaan;
  FaceLoginModel(
      {this.no,
      this.nik,
      this.nama,
      this.departemen,
      this.devisi,
      this.jabatan,
      this.flag,
      this.showAbsen,
      this.perusahaan});

  factory FaceLoginModel.fromJason(Map<String, dynamic> object) {
    return FaceLoginModel(
      no: object['no'],
      nik: object['nik'],
      nama: object['nama'],
      departemen: object['departemen'],
      devisi: object['devisi'],
      jabatan: object['jabatan'],
      flag: object['flag'],
      showAbsen: object['show_absen'],
      perusahaan: object['perusahaam'],
    );
  }

  static Future<FaceLoginModel?> loginApiFace(
      String username, String password) async {
    String apiUrl = "https://lp.abpjobsite.com/api/login/face";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"username": username, "password": password});
    var jsonObject = json.decode(apiResult.body);
    var dataLogin = (jsonObject as Map<String, dynamic>)['dataLogin'];
    var success = (jsonObject)['success'];
    if (success == true) {
      return FaceLoginModel.fromJason(dataLogin);
    } else {
      return null;
    }
  }
}
