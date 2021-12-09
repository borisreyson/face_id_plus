import 'package:face_id_plus/model/face_login_model.dart';
import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormLogin extends StatefulWidget {
  const FormLogin({Key? key}) : super(key: key);
  @override
  _FormLoginState createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  late FocusNode _usernameFocus, _passwordFocus;
  late String _username, _password;
  FaceLoginModel? postLogins;
  SharedPreferences? sharedPref;
  int? isLogin;
  bool _passwordVisible = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _roundedController =
      RoundedLoadingButtonController();
  @override
  void initState() {
    _passwordVisible = true;
    getPref(context);
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  _onLogin(BuildContext context) async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      _roundedController.start();
      form.save();
      String username = _username;
      String password = _password;
      FaceLoginModel.loginApiFace(username, password).then((value) {
        postLogins = value;
        if (postLogins != null) {
          setPref(
              1,
              postLogins!.nik!,
              postLogins!.nama!,
              postLogins!.departemen!,
              postLogins!.devisi!,
              postLogins!.jabatan,
              postLogins!.flag.toString(),
              postLogins!.showAbsen.toString(),
              postLogins!.perusahaan.toString());

          Future.delayed(const Duration(milliseconds: 1000), () {
            _roundedController.success();
            
            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.maybePop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage()));
            });
          });
        } else {
          _usernameFocus.requestFocus();
          Future.delayed(const Duration(milliseconds: 1000), () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Username/ Nik Atau Password Salah!!")));
            _roundedController.error();
            _usernameController.clear();
            _passwordController.clear();
            Future.delayed(const Duration(milliseconds: 1000), () {
              _roundedController.reset();
            });
          });
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _autoValidate = true;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Username/Nik Atau Password Tidak Boleh Kosong!!")));
        _usernameFocus.requestFocus();
          _roundedController.reset();
        
      });
    }
  }

  setPref(int login, String? nik, String? nama, String? departemen, String? jabatan,
      String? devisi,String? flag, String? perusahaan, String? showAbsen) async {
    sharedPref = await SharedPreferences.getInstance();
    sharedPref?.setInt("isLogin", login);
    sharedPref?.setString("nik", nik!);
    sharedPref?.setString("nama", nama!);
    sharedPref?.setString("departemen", departemen!);
    sharedPref?.setString("devisi", devisi!);
    sharedPref?.setString("jabatan", jabatan!);
    sharedPref?.setString("flag", flag!);
    sharedPref?.setString("showAbsen", showAbsen!);
    sharedPref?.setString("perusahaan", perusahaan!);
  }

  getPref(BuildContext context) async {
    sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref?.getInt("isLogin");
    if (isLogin == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
    } else {
      print("$isLogin || Not Login");
    }
  }

  void toggleVisible() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        elevation: 0,
        leading: InkWell(
          splashColor: const Color(0xff000000),
          child: const Icon(Icons.arrow_back_ios_new,color: Color(0xff000000),),
          onTap: () {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>const Splash()));
          },
        ),
      ),
      key: _globalKey,
      body: SafeArea(
          child: Container(
            color: const Color(0xffffffff),
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/ic_abp.png'),
                            fit: BoxFit.contain,
                          ),
                          color: Colors.white10),
                      margin: const EdgeInsets.only(top: 50.0),
                    )),
                TextFormField(
                  focusNode: _usernameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Username / NIK"),
                  onSaved: (value) {
                    _username = value!;
                  },
                  onFieldSubmitted: (term) {
                    _usernameFocus.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                  validator: (value) {
                    final isValidateUsername = RegExp(r'^[a-zA-Z0-9]*$');
                    if (value!.isEmpty) {
                      return 'Username Wajib Di Isi';
                    } else if (!isValidateUsername.hasMatch(value)) {
                      return 'Only letters are allowed';
                    }
                    return null;
                  },
                  controller: _usernameController,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  focusNode: _passwordFocus,
                  obscureText: _passwordVisible,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Password",
                      hintText: "Password",
                      suffixIcon: IconButton(
                          icon: _passwordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            _passwordFocus.unfocus();
                            toggleVisible();
                          })),
                  onSaved: (value) {
                    _password = value!;
                  },
                  onFieldSubmitted: (term) {
                    _passwordFocus.unfocus();
                    _onLogin(context);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password Wajib Di Isi';
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                    child: RoundedLoadingButton(
                        controller: _roundedController,
                        onPressed: () {
                          _roundedController.start();
                          _onLogin(context);
                        },
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ))),
              ],
            )),
      )),
    );
  }
}
