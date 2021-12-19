import 'package:flutter/material.dart';

class AbsenMasuk extends StatefulWidget {
  const AbsenMasuk({Key? key}) : super(key: key);

  @override
  _AbsenMasukState createState() => _AbsenMasukState();
}

class _AbsenMasukState extends State<AbsenMasuk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Boris"),
      ),
      body: Container(
          color: const Color(0xf0D9D9D9),
          height: double.maxFinite,
          child: Stack(
            children: [_coverContent(), _bottomContent()],
          ),
        )
    );
  }
  Widget _coverContent(){
    return Positioned(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Text("Masuk"),
      ),
    ));
  }
  Widget _bottomContent(){
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              onPressed: () {
              },
              child: Text("Scan Wajah")),
        ),
    );
  }
}
