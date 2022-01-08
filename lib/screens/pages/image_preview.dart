import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class ImagePreview extends StatelessWidget {
  final imglib.Image img;

  const ImagePreview({required this.img});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Image"),
      ),
      body: Center(child:Image.memory(Uint8List.fromList(img.data)))
    );
  }
}