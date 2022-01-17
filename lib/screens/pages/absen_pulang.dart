import 'dart:ffi';
import 'dart:ui';
import 'package:face_id_plus/model/upload.dart';
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
  final String nik;
  final String status;

  const AbsenPulang({ Key? key,required this.nik,required this.status }) : super(key: key);

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
  List<int>? intImage;

  static const shift = (0xFF << 24);

  void initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController =
          CameraController(cameras[cameraPick], ResolutionPreset.medium,enableAudio: false);

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
      if(cameras.isNotEmpty){
        cameraPick = 1;
      }
    }
    setState(() {
      cameraPick = cameraPick < cameras.length - 1 ? cameraPick + 1 : 0;
    });
  }


  @override
  void initState() {
    initializeCamera();
    conv = convertImageLib.lookup<NativeFunction<convert_func>>('convertImage').asFunction<Convert>();
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
            child: (visible) ? cameraFrame() : imgFrame()),
      floatingActionButton: (visible)? FloatingActionButton(
        onPressed: (isBusy)?null:(){
          isBusy=true;
          _processImageStream(_savedImage);
        },
        tooltip: 'Scan Wajah',
        child: const Icon(Icons.camera),
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
                child: (intImage != null)
                    ? Image.memory(Uint8List.fromList(intImage!))
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
                        detect=false;
                        initializeCamera();
                        conv = convertImageLib.lookup<NativeFunction<convert_func>>('convertImage').asFunction<Convert>();
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
      ],
    );
  }

  Widget cameraPreview() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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

  Future<void> processImage(InputImage inputImage) async {
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
      intImage =  await convertImage(_savedImage);
      _cameraInitialized=false;
      _stopLiveFeed();
      savingImage();
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
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
  Future<List<int>> convertImage(CameraImage image) async {
      if(Platform.isAndroid){
        // Allocate memory for the 3 planes of the image
        Pointer<Uint8> p = calloc(_savedImage.planes[0].bytes.length);
        Pointer<Uint8> p1 = calloc(_savedImage.planes[1].bytes.length);
        Pointer<Uint8> p2 = calloc(_savedImage.planes[2].bytes.length);

        // Assign the planes data to the pointers of the image
        Uint8List pointerList = p.asTypedList(_savedImage.planes[0].bytes.length);
        Uint8List pointerList1 = p1.asTypedList(_savedImage.planes[1].bytes.length);
        Uint8List pointerList2 = p2.asTypedList(_savedImage.planes[2].bytes.length);
        pointerList.setRange(0, _savedImage.planes[0].bytes.length, _savedImage.planes[0].bytes);
        pointerList1.setRange(0, _savedImage.planes[1].bytes.length, _savedImage.planes[1].bytes);
        pointerList2.setRange(0, _savedImage.planes[2].bytes.length, _savedImage.planes[2].bytes);

        // Call the convertImage function and convert the YUV to RGB
        Pointer<Uint32> imgP = conv(p, p1, p2, _savedImage.planes[1].bytesPerRow,
        _savedImage.planes[1].bytesPerPixel!, _savedImage.planes[0].bytesPerRow, _savedImage.height);

        // Get the pointer of the data returned from the function to a List
        List<int> imgData = imgP.asTypedList((_savedImage.planes[0].bytesPerRow * _savedImage.height));
        // Generate image from the converted data
        img = imglib.Image.fromBytes(_savedImage.height, _savedImage.planes[0].bytesPerRow, imgData);
        // Free the memory space allocated
        // from the planes and the converted data        calloc.free(p);
        calloc.free(p1);
        calloc.free(p2);
        calloc.free(imgP);
      }else if(Platform.isIOS){
        img = imglib.Image.fromBytes(
        _savedImage.planes[0].bytesPerRow,
        _savedImage.height,
        _savedImage.planes[0].bytes,
        format: imglib.Format.bgra,
        );
      }
      img= imglib.flipVertical(img);
      img = imglib.copyCrop(img, 0, 100, img.width, img.height-100);
      imglib.PngEncoder pngEncoder = imglib.PngEncoder();
      return pngEncoder.encodeImage(img);
    }
    savingImage() async{
      externalDirectory  = await getApplicationDocumentsDirectory();
      String directoryPath = '${externalDirectory.path}/FaceIdPlus';
      await Directory(directoryPath).create(recursive: true);
      String filePath = '$directoryPath/${DateTime.now()}_pulang.jpg';
      File _files = await File(filePath).writeAsBytes(intImage!);
      print("Filess ${_files}");
      absensiPulang(_files);
  }
  absensiPulang(File files)async{
    var uploadRes = await Upload.uploadApi(widget.nik, widget.status, files);
    print("UploadResult ${uploadRes}");
    if(uploadRes!=null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,
          content: Text("Absen Di Daftar!",style: TextStyle(color: Colors.white),)));
      visible = false;
      detect=true;
      isBusy=false;
      setState(() {
      });
    }
  }
}