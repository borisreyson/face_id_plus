import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'painters/face_detector_painter.dart';
import 'dart:ui' as ui show Image;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as imglib;

class AbsenPulang extends StatefulWidget {
  const AbsenPulang({ Key? key }) : super(key: key);

  @override
  _AbsenPulangState createState() => _AbsenPulangState();
}

class _AbsenPulangState extends State<AbsenPulang> {
  var externalDirectory ;
  late final Function(InputImage inputImage) onImage;
  late CameraImage _savedImage;
  bool _cameraInitialized = false;
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
          enableContours: true, enableClassification: true));
  bool isBusy = false;
  CustomPaint? customPaint;
  CameraController? _cameraController;
  bool visible = true;
  bool detect = false;
  File? imageFile;
  int cameraPick = 1;
  late List<CameraDescription> cameras;
  void initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController =
          CameraController(cameras[cameraPick], ResolutionPreset.medium);

      await _cameraController!.initialize().then((_) async {
        // Start ImageStream
        await _cameraController!.startImageStream((CameraImage image) =>
            _processCameraImage(image));
        setState(() {
          _cameraInitialized = true;
        });
      } );
    }
  }
  void _processCameraImage(CameraImage image) async {
    setState(() {
      _savedImage = image;
    });
        }
  Future<void> initCameras() async {

    if(cameras.isNotEmpty){
      if(cameras.length > 0){
        cameraPick = 1;
      }
    }
    setState(() {
      cameraPick = cameraPick < cameras.length - 1 ? cameraPick + 1 : 0;
    });
  }

  Future<File> takePicture() async {
    externalDirectory  = await getApplicationDocumentsDirectory();
    String directoryPath = '${externalDirectory.path}/FaceIdPlus';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}_pulang.jpg';
    try {
      XFile image = await _cameraController!.takePicture();
      image.saveTo(filePath);
    } catch (e) {
      print('Error : ${e.toString()}');
      // return null;
    }
    var files = File(filePath);
    var saving =await files.create(recursive: true);
    print("Saving $saving");
    return files;
  }

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }
  Future _stopLiveFeed() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    await faceDetector.close();
    _cameraController = null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Absen Pulang"),
            leading: InkWell(
              splashColor: const Color(0xff000000),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.maybePop(context);
              },
            )),
        body: Container(
            color: const Color(0xf0D9D9D9),
            height: double.maxFinite,
            child: (visible) ? cameraFrame() : imgFrame()),
      floatingActionButton: (visible)? FloatingActionButton(
        onPressed: (){
          print("Save image $_savedImage");
          _processImageStream(_savedImage);
        },
        tooltip: 'Scan Wajah',
        child: Icon(Icons.camera),
      ):Visibility(visible: false,child: Container(),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }

  Widget imgFrame() {
    return Stack(
      children: [
        Positioned(
            child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: (imageFile != null)
                    ? Image.file(imageFile!, fit: BoxFit.fill)
                    : Container()),
            if (customPaint != null) customPaint!,
          ],
        )),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: (detect)
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    child: const Text("Selesai"))
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        visible = true;
                      });
                    },
                    child: const Text("Scan Ulang")),
          ),
        )
      ],
    );
  }

  Widget cameraFrame() {
    return Stack(
      children: [
        (_cameraInitialized) ?Container(
          child: cameraPreview(),
        ):
        const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
        ),
        (visible) ? _bottomContent() : Container()
      ],
    );
  }

  // Widget _coverContent() {
  //   return Positioned(
  //       child: FutureBuilder(
  //           future: initializeCamera(),
  //           builder: (context, snapshot) =>
  //               (snapshot.connectionState == ConnectionState.done)
  //                   ? Container(
  //                       child: cameraPreview(),
  //                     )
  //                   : const Center(
  //   //                       child: SizedBox(
  //   //                         height: 20,
  //   //                         width: 20,
  //   //                         child: CircularProgressIndicator(),
  //   //                       ),
  //   //                     )));
  // }

  Widget cameraPreview() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GestureDetector(
            onDoubleTap: () {
                initCameras();
              print("Double Tap");
            },
            child: (_cameraController != null)
                ? CameraPreview(_cameraController!)
                : const Center(
                    child: Text("Camera Tidak Tersedia!"),
                  )));
  }

  Widget _bottomContent() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: Visibility(
          visible: false,
          child: ElevatedButton(
              onPressed: () async {
                if (!_cameraController!.value.isTakingPicture) {
                  ImagePicker picker = ImagePicker();
                  File result = await takePicture();
                  _localFile;
                  InputImage image = InputImage.fromFile(result);
                  print("detect $image");
                  print("detect $result");
                  print("TAKE PICTURE");
                  setState(() {
                    // imageFile= result;
                    processImage(image);
                    visible = false;
                  });
                }
              },
              child: const Text("Scan Wajah")),
        ),
      ),
    );
  }
  Future<void> processImage(InputImage inputImage) async {
    print("Mulai detect");
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);

      print("Di detect");
      print("Di detect ${_savedImage}");
      // _stopLiveFeed();
      // setState(() {
      //   imageFile = File.fromRawPath(inputImage.filePath!);
        _cameraInitialized=false;
        visible = false;
      // });
    } else {
      customPaint = null;
      print("Tidak di detect");
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    print("Lokasi $path");
    return File('$path/data.txt');
  }
  Future<File> writeContent() async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('Hello Folks');
  }
  Future _processImageStream(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[cameraPick];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    processImage(inputImage);
  }
}