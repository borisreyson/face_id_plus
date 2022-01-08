import 'dart:ffi';
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

typedef convert_func = Pointer<Uint32> Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class AbsenPulang extends StatefulWidget {
  const AbsenPulang({ Key? key }) : super(key: key);

  @override
  _AbsenPulangState createState() => _AbsenPulangState();
}

class _AbsenPulangState extends State<AbsenPulang> {
  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  late Convert conv;
  late imglib.Image img;
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


  static const shift = (0xFF << 24);
  Future<imglib.Image?> convertYUV420toImageColor(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int? uvPixelStride = image.planes[1].bytesPerPixel;

      print("uvRowStride: " + uvRowStride.toString());
      print("uvPixelStride: " + uvPixelStride.toString());

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img = imglib.Image(width, height); // Create Image buffer

      // Fill image buffer with plane[0] from YUV420_888
      for(int x=0; x < width; x++) {
        for(int y=0; y < height; y++) {
          final int uvIndex = uvPixelStride! * (x/2).floor() + uvRowStride*(y/2).floor();
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          img.data[index] = shift | (b << 16) | (g << 8) | r;
        }
      }

      imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
      var png = pngEncoder.encodeImage(img);
      // muteYUVProcessing = false;
      return img;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }
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
    conv = convertImageLib.lookup<NativeFunction<convert_func>>('convertImage').asFunction<Convert>();
    super.initState();
  }
  Future<List<int>?> convertImagetoPng(CameraImage image) async {
    try {

      if (image.format.group == ImageFormatGroup.yuv420) {
        img = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
      }

      imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

      // Convert to png
      List<int> png = pngEncoder.encodeImage(img);
      return png;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

// CameraImage BGRA8888 -> PNG
// Color
  imglib.Image _convertBGRA8888(CameraImage image) {
    return imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    );
  }

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
  imglib.Image _convertYUV420(CameraImage image) {
    var img = imglib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
      planeOffset < image.height * image.width;
      planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return img;
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
      var image = await convertYUV420toImageColor(_savedImage);
      print("Di detect");
      print("Di detect ${image!.data}");
      // _stopLiveFeed();
      // setState(() {
        _cameraInitialized=false;
        visible = false;
        imageFile = await File('thumbnail.png').writeAsBytes(image.data);

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