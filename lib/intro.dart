import 'package:face_id_plus/screens/pages/home.dart';
import 'package:face_id_plus/splash.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:shared_preferences/shared_preferences.dart';

class SliderIntro extends StatefulWidget {
  const SliderIntro({Key? key}) : super(key: key);

  @override
  _SliderIntroState createState() => _SliderIntroState();
}

class _SliderIntroState extends State<SliderIntro> {
  List<Slide> slides = [];
  Function? gotoTab;
  bool doneVisible=false;
  Color textColor= Color.fromRGBO(13,13,13,1.0);
  int isLogin = 0;
  bool _serviceEnabled = false;
  bool? intro=false;
  bool visbleIntro=false;
  @override
  void initState() {
    if(!visbleIntro) {
      checkIntro(context);
    }
    slides.add(
        Slide(
          title: "Selamat Datang",
          styleTitle: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description:
          "Aplikasi Ini Dibuat Untuk Absensi Karyawan",
          styleDescription: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          backgroundColor: Color.fromRGBO(41,52,67,1.0),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          onCenterItemPress: () {
            print("Tab 1");
          },
            pathImage: "assets/images/abp_60x60.png"
        )
    );
    slides.add(
        Slide(
          title: "Izin ",
          styleTitle: TextStyle(
              color: textColor,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description:
          "Aplikasi Ini Membutuhkan Izin Untuk Penggunaan Internet, lihat sambungan Wi-Fi, "+
              "Penyimpanan Internal dan External untuk menyimpan data atau foto sementara sebelum di upload ke server",
          styleDescription: TextStyle(
              color: textColor,
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          centerWidget: Text("Penggunaan Koneksi Jaringan",
              style: TextStyle(color: textColor)),
          backgroundColor: Color.fromRGBO(186,183,172,1.0),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          onCenterItemPress: () {},
        )
    );
    slides.add(
        Slide(
          title: "Izin",
          styleTitle: TextStyle(
              color: Color.fromRGBO(96,55,30,1.0),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description:
          "Aplikasi Ini Membutuhkan Izin Untuk Penggunaan Camera, Audio , Video untuk pengambilan gambar, "+
              "Mikrofon, memodifikasi atau menghapus konten penyimpanan USB Anda, membaca konten penyimpanan USB Anda",
          styleDescription: TextStyle(
              color: Color.fromRGBO(96,55,30,1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          centerWidget: Text("Penggunaan Kamera Dan Penyimpanan",
              style: TextStyle(color: Color.fromRGBO(96,55,30,1.0))),
          backgroundColor: Color.fromRGBO(252,190,64,1.0),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          onCenterItemPress: () {},
        )
    );
    slides.add(
        Slide(
          title: "Izin",
          styleTitle: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description:
          "Aplikasi Ini Membutuhkan Izin Untuk Penggunaan baca identitas dan status ponsel, terima data dari internet, "
              "lihat koneksi jaringan, akses jaringan penuh, cegah perangkat agar tidak tidur",
          styleDescription: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          centerWidget: Text("Akses penuh jaringan dan ponsel",
              style: TextStyle(color: Color.fromRGBO(242, 242, 240, 1.0))),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          backgroundColor: Color.fromRGBO(101,87,53,1.0),
          onCenterItemPress: () {},
        )
    );
    slides.add(
        Slide(
          title: "Izin Lokasi",
          styleTitle: TextStyle(
              color: Color.fromRGBO(166, 52, 27, 1.0),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description:
          "Aplikasi Ini Membutuhkan Izin Untuk Penggunaan Lokasi Terkini Untuk mendeteksi posisi ponsel berada atau tidak di area yang sudah di tentukan untuk penggunaan, "+
              "data lokasi tidak di sebar luaskan , hanya diambil untuk mengetahui lokasi di dalam area atau tidak!",
          styleDescription: TextStyle(
              color: Color.fromRGBO(166, 52, 27, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          backgroundColor: Color.fromRGBO(234,173,57,1.0),
          onCenterItemPress: () {},
          pathImage: "assets/images/abp_maps.png"
        )
    );
    slides.add(
        Slide(
          title: "Permintaan Izin",
          styleTitle: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          styleDescription: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),
          marginDescription:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 70.0),
          centerWidget: Text("Izin Penyimpanan, Izin Lokasi, Izin Ponsel, Izin Kamera , Izin Mikropon",
              style: TextStyle(color: Color.fromRGBO(242, 242, 240, 1.0)),textAlign: TextAlign.center,),
          backgroundColor: Color.fromRGBO(191,85,23,1.0),
          directionColorBegin: Alignment.topLeft,
          directionColorEnd: Alignment.bottomRight,
          onCenterItemPress: () {},
          widgetDescription: costomWidget()
        )
    );
    super.initState();
  }
  Widget costomWidget(){
    return Container(
      child: Column(
        children: [
          Text("Mohon Untuk Mengizinkan Penggunaan Internet ",style: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),textAlign: TextAlign.center,),
          Text("Penyimpanan Internal dan Penyimpanan External supaya aplikasi ini berjalan dengan baik",style: TextStyle(
              color: Color.fromRGBO(242, 242, 240, 1.0),
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'Raleway'),textAlign: TextAlign.center,),
        ],
      ),
    );

  }
  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Color(0x33F3B4BA)),
      overlayColor: MaterialStateProperty.all<Color>(Color(0x33FFA8B0)),
    );
  }
  ButtonStyle nextButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
      backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(242, 242, 242, 1.0)),
      overlayColor: MaterialStateProperty.all<Color>(Color.fromRGBO(199, 200, 196, 1.0)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visbleIntro,
      child: IntroSlider(
        slides:this.slides,
        doneButtonStyle: nextButtonStyle(),
        onDonePress: (){
          _requestLocation(context);
        },
        showDoneBtn: true,
        showSkipBtn: false,
        renderNextBtn: nextButton(),
        nextButtonStyle: nextButtonStyle(),
        renderPrevBtn: prevButton(),
        prevButtonStyle: nextButtonStyle(),
        renderDoneBtn: doneButton(),
      ),
    );
  }
  Widget nextButton(){
    return Icon(Icons.navigate_next,color: Color.fromRGBO(115, 2, 2, 1.0));
  }
  Widget prevButton(){
    return Icon(Icons.navigate_before,color: Color.fromRGBO(115, 2, 2, 1.0));
  }
  Widget doneButton(){
    return InkWell(child: Text("Setujui",style: TextStyle(color:Color.fromRGBO(96,55,30,1.0))));
  }
  _requestLocation(BuildContext context) async {
    int z =0;
    var status = await handler.Permission.location.status;
    var camStat = await handler.Permission.camera.status;
    var storage = await handler.Permission.storage.status;
    Map<handler.Permission, handler.PermissionStatus> _statuses = await [
      handler.Permission.location,
      handler.Permission.locationAlways,
      handler.Permission.locationWhenInUse,
      handler.Permission.storage,
      handler.Permission.camera,
      handler.Permission.microphone,
      handler.Permission.phone
    ].request();
    _statuses.forEach((key, value) {
      print("permission ${key}  - ${value}");
      if(value==handler.PermissionStatus.granted){
        z++;
      }else{
        if(value.isPermanentlyDenied){
          handler.openAppSettings();
        }else if(value.isDenied || value.isRestricted){
          key.request();
        }
      }
    });
    if(z==_statuses.length){
      print("OK");
      saveIntro(context);
    }else{
      doneVisible = false;
      _statuses = await [
        handler.Permission.location,
        handler.Permission.locationAlways,
        handler.Permission.locationWhenInUse,
        handler.Permission.storage,
        handler.Permission.camera,
        handler.Permission.microphone,
        handler.Permission.phone
      ].request();
      _statuses.forEach((key, value) {
        print("permission ${key}  - ${value}");
        if(value==handler.PermissionStatus.granted){
          z++;
        }else{
          if(value.isPermanentlyDenied){
            handler.openAppSettings();
          }else if(value.isDenied || value.isRestricted){
            key.request();
          }
        }
      });
    }
    // print("Permission Status : $status");
    // if (status.isDenied) {
    //   print("Permission Status ABC");
    //   return handler.openAppSettings();
    // }
    // if (status.isPermanentlyDenied) {
    //   handler.openAppSettings();
    // }
    // if (status.isGranted) {
    //   _statuses;
    // }
    // if (status.isRestricted) {
    //   handler.openAppSettings();
    // }
    // if(camStat.isDenied){
    //   handler.Permission.camera.request();
    // }
    // if(camStat.isPermanentlyDenied){
    //   handler.openAppSettings();
    // }
    // if(camStat.isRestricted){
    //   handler.openAppSettings();
    // }
    // if(storage.isDenied){
    //   handler.Permission.storage.request();
    // }
    // if(storage.isPermanentlyDenied){
    //   handler.openAppSettings();
    // }
    // if(storage.isRestricted){
    //   handler.openAppSettings();
    // }
  }
  checkIntro(BuildContext context) async{
    SharedPreferences? _pref = await SharedPreferences.getInstance();
    intro = _pref.getBool("introSlider");
    print("intro $intro");
    if(intro!=null){
      if(intro!){
        getPref(context);
      }else{
        setState(() {
          visbleIntro = true;
        });
      }
    }else{
      setState(() {
        visbleIntro = true;
      });
    }

  }
  saveIntro(BuildContext context)async{
    var pref = await SharedPreferences.getInstance();
      pref.setBool("introSlider", true);
      checkIntro(context);
  }
  getPref(BuildContext context) async {
    var sharedPref = await SharedPreferences.getInstance();
    isLogin = sharedPref.getInt("isLogin") ?? 0;
    print("LoginStatus $isLogin");
    if (isLogin == 1) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Splash()));
    }
  }
}
