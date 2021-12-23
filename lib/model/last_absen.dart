import 'package:http/http.dart' as http;
import 'dart:convert';

class LastAbsen {
  String? lastAbsen;
  String? lastNew;
  String? tanggal;
  String? masuk;
  String? pulang;
  Presensi? presensiMasuk;
  Presensi? presensiPulang;
  LastAbsen(
      {this.lastAbsen,
      this.lastNew,
      this.tanggal,
      this.masuk,
      this.pulang,
      this.presensiMasuk,
      this.presensiPulang});

  factory LastAbsen.fromJson(Map<String, dynamic> object) {
    return LastAbsen(
      lastAbsen: object['lastAbsen'],
      lastNew: object['lastNew'],
      tanggal: object['tanggal'],
      masuk: object['masuk'],
      pulang: object['pulang'],
      presensiMasuk: (object['presensiMasuk'] != null)
          ? Presensi.fromJson(object['presensiMasuk'])
          : null,
      presensiPulang: (object['presensiPulang'] != null)
          ? Presensi.fromJson(object['presensiPulang'])
          : null,
    );
  }

  static Future<LastAbsen> apiAbsenTigaHari(String _nik) async {
    String apiUrl = "https://abpjobsite.com/absen/get/lastAbsen?nik=" + _nik;
    var apiResult = await http.get(Uri.parse(apiUrl));
    var jsonObject = json.decode(apiResult.body);
    var lastAbsen = LastAbsen.fromJson(jsonObject);
    return lastAbsen;
  }
}

class Presensi {
  int? id;
  int? idRoster;
  String? nik;
  String? tanggal;
  String? jam;
  String? gambar;
  String? status;
  String? faceId;
  int? flag;
  String? lupaAbsen;
  String? timeIn;
  String? tanggalJam;
  Presensi(
      {this.id,
      this.nik,
      this.tanggal,
      this.jam,
      this.gambar,
      this.status,
      this.faceId,
      this.flag,
      this.lupaAbsen,
      this.timeIn,
      this.tanggalJam});
  factory Presensi.fromJson(Map<String, dynamic> object) {
    return Presensi(
      id: object['id'],
      nik: object['nik'],
      tanggal: object['tanggal'],
      jam: object['jam'],
      gambar: object['gambar'],
      status: object['status'],
      faceId: object['nik'],
      flag: object['flag'],
      lupaAbsen: object['lupa_absen'],
      timeIn: object['time_in'],
      tanggalJam: object['tanggal_jam'],
    );
  }
}
