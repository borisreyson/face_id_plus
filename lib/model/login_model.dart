import 'package:http/http.dart' as http;
import 'dart:convert';

class PostLogin {
  int? idUser;
  String? username;
  String? namaLengkap;
  String? nik;
  String? rule;
  String? department;
  String? perusahaan;
  String? photoProfile;
  PostLogin({
    this.idUser,
    this.username,
    this.namaLengkap,
    this.nik,
    this.rule,
    this.department,
    this.perusahaan,
    this.photoProfile,
  });

  factory PostLogin.fromJson(Map<String, dynamic> object) {
    return PostLogin(
        idUser: object['id_user'],
        username: object['username'],
        namaLengkap: object['nama_lengkap'],
        nik: object['nik'],
        rule: object['rule'],
        perusahaan: object['perusahaan'].toString(),
        photoProfile: object['photo_profile']);
  }
  static Future<PostLogin?> loginToApi(String username, String password) async {
    String apiUrl = "https://lp.abpjobsite.com/api/login";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"username": username, "password": password});
    var jsonObject = json.decode(apiResult.body);
    var userData = (jsonObject as Map<String, dynamic>)['user'];
    var status = (jsonObject)['success'];
    if (status==true) {
      return PostLogin.fromJson(userData);
    } else {
      return null;
    }
  }
}
