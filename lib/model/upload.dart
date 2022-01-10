import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Upload {
  String? image;
  String? res;
  bool? tidakDikenal;

  Upload({this.image, this.res, this.tidakDikenal});
  factory Upload.fromJson(Map<String, dynamic> object) {
    return Upload(
        image: object['image'],
        res: object['res'],
        tidakDikenal: object['tidak_dikenal']);
  }
  static Future<Upload> uploadApi(String nik, String status, File file) async {
    Map<String, dynamic>? data;

    String tgl = "";
    String jam = "";
    String apiUrl = "https://abpjobsite.com/upload_image.php";
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.fields['id'] = "0";
    request.fields['nik'] = nik;
    request.fields['tgl'] = tgl;
    request.fields['jam'] = jam;
    request.fields['status'] = status;
    String filename = nik + "_" + status + DateTime.now().toString() + ".jpg";
    request.files.add(http.MultipartFile.fromBytes(
        "fileToUpload", await file.readAsBytes(),
        filename: filename));

    var response = await request.send();
    await for (String s in response.stream.transform(utf8.decoder)) {
      data = jsonDecode(s);
    }
    return Upload.fromJson(data!);
  }
}
