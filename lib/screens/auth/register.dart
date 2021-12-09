import 'package:flutter/material.dart';

class FormRegister extends StatefulWidget {
  const FormRegister({Key? key}) : super(key: key);

  @override
  _FormRegisterState createState() => _FormRegisterState();
}

class _FormRegisterState extends State<FormRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
              onPressed: () {
                Navigator.maybePop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
        ),
      ),
    );
  }
}
