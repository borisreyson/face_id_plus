import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginValidate {
  bool? success = false;
  PostLogin? user;
  LoginValidate({this.success, this.user});

  factory LoginValidate.fromJson(Map<String, dynamic> object) {
    return LoginValidate(
        success: object['success'],
        user: (object['user'] != null)
            ? PostLogin.fromJson(object['user'])
            : null);
  }
  static Future<LoginValidate?> loginToApi(
      String username, String password) async {
    String apiUrl = "https://lp.abpjobsite.com/api/login";
    var apiResult = await http.post(Uri.parse(apiUrl),
        body: {"username": username, "password": password});
    var jsonObject = json.decode(apiResult.body);
    print("UserLogin = $jsonObject");
    return LoginValidate.fromJson(jsonObject);
  }
}

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
        department: object['department'].toString(),
        perusahaan: object['perusahaan'].toString(),
        photoProfile: object['photo_profile']);
  }
}
