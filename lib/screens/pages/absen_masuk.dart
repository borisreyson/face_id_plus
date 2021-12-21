import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'painters/face_detector_painter.dart';

class AbsenMasuk extends StatefulWidget {
  const AbsenMasuk({Key? key}) : super(key: key);
  @override
  _AbsenMasukState createState() => _AbsenMasukState();
}

class _AbsenMasukState extends State<AbsenMasuk> {
  late final Function(InputImage inputImage) onImage;
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(enableContours: true,enableClassification: true));
  ImagePicker? _imagePicker;
  bool isBusy=false;
  CustomPaint? customPaint;
  late CameraController _cameraController;
  bool visible = true;
  bool detect = false;
  File? imageFile;
  int cameraPick=0;
  late List<CameraDescription> cameras;
  Future<void> initializeCamera() async{
    cameras = await availableCameras();
    print("Cameras : $cameras");
    _cameraController = CameraController(cameras[cameraPick], ResolutionPreset.medium);
    await _cameraController.initialize();
  }
  Future<void> initCameras()async{
    setState(() {
      cameraPick = cameraPick < cameras.length -1 ? cameraPick + 1 : 0;
      print("Cameras : $cameraPick");
    });
  }
  Future<File> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/FaceIdPlus';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}.jpg';
    try{
      XFile image = await _cameraController.takePicture();
      image.saveTo(filePath);
    }catch (e){
      print('Error : ${e.toString()}');
      // return null;
    }
    return File(filePath);
  }
@override
  void initState() {
  _imagePicker = ImagePicker();
  initCameras();
    super.initState();
  }
  @override
  void dispose(){
    _cameraController.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Absen Masuk"),
        leading: InkWell(
          splashColor: const Color(0xff000000),
          child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              ),
          onTap: (){
            Navigator.maybePop(context);
          },
        )
      ),
      body: Container(
          color: const Color(0xf0D9D9D9),
          height: double.maxFinite,
          child: (visible)?cameraFrame():imgFrame()
        )
    );
  }
  Widget imgFrame(){
    return Stack(
      children: [
        Positioned(child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height,
               child: (imageFile!=null)?Image.file(imageFile!,fit: BoxFit.fill):Container()
            ),
            if(customPaint!=null) customPaint!,
          ],
        )),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child:
            (detect)?
            ElevatedButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },child: Text("Selesai")):
            ElevatedButton(
              onPressed: () {
              setState(() {
                visible = true;
              });
              },
              child: Text("Scan Ulang")),
          ),
        )
      ],
    );
  }
  Widget cameraFrame(){
    return Stack(
      children: [_coverContent(), _bottomContent()],
    );
  }
  Widget _coverContent(){
    return Positioned(
        child: FutureBuilder(
            future: initializeCamera(),
            builder: (context, snapshot)=>
        (snapshot.connectionState==ConnectionState.done)? Container(child: cameraPreview(),):Center(child: SizedBox(height: 20,width: 20,child: CircularProgressIndicator(),),)));
  }
  Widget cameraPreview(){
    return SizedBox(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GestureDetector(
            onDoubleTap: (){
              initCameras();
              print("Double Tap");
            },
            child: CameraPreview(_cameraController)));
  }
  Widget _bottomContent(){
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              onPressed: () async {
                if(!_cameraController.value.isTakingPicture){
                  File result = await takePicture();
                  InputImage image = InputImage.fromFile(result);
                  print("detect ${image}");
                    print("TAKE PICTURE");
                  setState(() {
                    processImage(image);
                    visible = false;
                  });
                }
              },
              child: Text("Scan Wajah")),
        ),
    );
  }

  Future<void> processImage(InputImage inputImage) async{
    print("Mulai detect");
    if(isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);

    if(inputImage.inputImageData?.size!=null && inputImage.inputImageData?.imageRotation!=null){
      final painter = FaceDetectorPainter(faces, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
      print("Di detect");
    }else{
      customPaint = null;
      print("Tidak di detect");

    }
    isBusy = false;
    if(mounted){
      setState(() {

      });
    }
  }
}
