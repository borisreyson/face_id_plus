import 'package:camera/camera.dart';
import 'package:face_id_plus/screens/pages/camera_view.dart';
import 'package:face_id_plus/screens/pages/painters/face_detector_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MasukAbsen extends StatefulWidget {
  const MasukAbsen({Key? key}) : super(key: key);

  @override
  _MasukAbsenState createState() => _MasukAbsenState();
}

class _MasukAbsenState extends State<MasukAbsen> {
  FaceDetector faceDetector =
  GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {
        print("Mounted : ${mounted}");
        if(faces.length==1){
          Future.delayed(const Duration(milliseconds: 1000));
          Navigator.maybePop(context,inputImage.filePath);
        }
      });
    }

  }
}
