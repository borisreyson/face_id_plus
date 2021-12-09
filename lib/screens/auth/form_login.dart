// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:abp_energy_aoe/model/LoginModel.dart';

// TextEditingController usernameCtr = TextEditingController();
// TextEditingController passwordCtr = TextEditingController();
// FocusNode userFocus = FocusNode();
// PostLogin? postLogins;
// String? text = "Login";
// FocusNode _usernameFocus, _passwordFocus;
// String _username, _password;
// int? isLogin = null;
// bool _passwordDisable = true;
// SharedPreferences? sharedPref;
// final _formKey = GlobalKey<FormState>();

// class FormLogin extends StatefulWidget {
//   const FormLogin({Key? key}) : super(key: key);

//   @override
//   State<FormLogin> createState() => _FormLoginState();
// }

// class _FormLoginState extends State<FormLogin> {
//   @override
//   void initState() {
//     _usernameFocus = FocusNode();
//     _passwordFocus = FocusNode();
//     getPref(context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         Padding(
//             padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/ic_abp.png'),
//                     fit: BoxFit.contain,
//                   ),
//                   color: Colors.white10),
//               margin: EdgeInsets.only(top: 50.0),
//             )),
//         Form(
//           key: _formKey,
//           child: Stack(
//             children: <Widget>[
//               TextFormField(
//                 focusNode: _usernameFocus,
//                 textInputAction: TextInputAction.next,
//                 decoration: const InputDecoration(
//                     border: OutlineInputBorder(), labelText: "Username"),
//                 onSaved: (String value) {
//                   _username = value;
//                 },
//                 onFieldSubmitted: (term) {
//                   _usernameFocus.unfocus();
//                 },
//               )
//             ],
//           ),
//         )
//       ],
//     );
//     //KEMUDIAN MENGGUNAKAN STACK AGAR MUDAH MENGATUR LETAKNNYA SESUAI KEINGINAN
//     //KARENA KITA INGIN GAMBAR HEADER DAN FORM LOGIN SALING MEMBELAH
//   }
// }

// // Future<LoginResponse> loginSubmit(BuildContext context) async {
// //   String username = usernameCtr.text;
// //   String password = passwordCtr.text;
// //   final response = await http.post(Uri.parse("${_baseUrl}/api/login"),
// //       headers: {"Accept": "application/json"},
// //       body: jsonEncode(
// //           <String, String>{'username': username, 'password': password}));
// //   print(response.reasonPhrase);
// //   if (response.statusCode == 200) {
// //     final json = jsonDecode(response.body);
// //     var jsonRes = LoginResponse.fromJson(json);
// //     if (jsonRes.success) {
// //     print("${jsonRes.success}");
// //       Navigator.of(context).pushNamed("/home");
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //           content: Text("Username : ${username} |  Password : ${password}")));
// //     } else {
// //     print("${username} ${password}");

// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //         content: Text("Username atau  Password Salah"),
// //         backgroundColor: Colors.red,
// //       ));
// //     }
// //     return jsonRes;
// //     // return LoginResponse.fromJson(json);
// //   } else {
// //     throw Exception('${response.statusCode}');
// //   }
// // }

// void kirimData(BuildContext context) {
//   if (_formKey.currentState!.validate()) {
//     String username = usernameCtr.text;
//     String password = passwordCtr.text;
//     PostLogin.loginToApi(username, password).then((value) {
//       postLogins = value;
//       if (postLogins != null) {
//         setPref(
//             1,
//             postLogins!.username!,
//             postLogins!.namaLengkap!,
//             postLogins!.nik!,
//             postLogins!.rule!,
//             postLogins!.department,
//             postLogins!.perusahaan!,
//             postLogins!.photoProfile!);
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Login Berhasil!!")));
//         Future.delayed(const Duration(milliseconds: 500), () {
//           Navigator.of(context).pushNamed("/login");
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Username Atau Password Salah!!")));
//         userFocus.requestFocus();

//         usernameCtr.clear();
//         passwordCtr.clear();
//       }
//     });
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Username Atau Password Tidak Boleh Kosong!!")));
//     userFocus.requestFocus();

//     usernameCtr.clear();
//     passwordCtr.clear();
//   }

//   // userFocus.requestFocus();
// }

// setPref(int login, String username, String nama, String nik, String rule,
//     String? departemen, String perusahaan, String photoProfile) async {
//   sharedPref = await SharedPreferences.getInstance();
//   sharedPref?.setInt("isLogin", login);
//   sharedPref?.setString("username", username);
//   sharedPref?.setString("nama", nama);
//   sharedPref?.setString("nik", nik);
//   sharedPref?.setString("rule", rule);
//   if (departemen != null) {
//     sharedPref?.setString("departemen", departemen);
//   }
//   sharedPref?.setString("perusahaan", perusahaan);
//   sharedPref?.setString("photo_profile", photoProfile);
// }

// getPref(BuildContext context) async {
//   sharedPref = await SharedPreferences.getInstance();
//   isLogin = sharedPref?.getInt("isLogin");
//   if (isLogin == 1) {
//     Navigator.pushNamedAndRemoveUntil(
//         context, "/home", ModalRoute.withName("/home"));
//   } else {
//     print("$isLogin || Not Login");
//   }
//   //     ? Navigator.of(context).pushNamed("/login")
//   //     : print("$isLogin");
// }

// void visible() {
//   if (_passwordDisable) {
//     _passwordDisable = !_passwordDisable;
//   }
// }
// // class NotificationPage extends StatefulWidget {
// //   @override
// //   // State<StatefulWidget> createState() => NotificationPageState();
// // }
// // class NotificationPageState extends State<NotificationPage>{
// //   FirebaseMessaging fm = FirebaseMessaging.instance;
// //   NotificationPageState(){
// //     // fm.configure();
// //   }
// //   // @override
// //   // Widget build(BuildContext context) {
// //   //
// //   // }
// // }