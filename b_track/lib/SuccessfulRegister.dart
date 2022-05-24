// ignore_for_file: camel_case_types, use_key_in_widget_constructors, prefer_const_constructors, file_names, prefer_final_fields, unused_field, unused_element, annotate_overrides

import 'package:b_track/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class successpage1 extends StatefulWidget {
  @override
  _successpage1 createState() => _successpage1();
}

class _successpage1 extends State<successpage1> {
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => login())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () {},
        ),
        title: Text('Register',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xff343b71),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                height: 400,
                padding: EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Color(0xff343b71),
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/images/handshake.png",
                    height: 220, width: 220)),
            SizedBox(height: 20),
            Text(
              "Registerd\nSuccessfully!",
              textAlign: TextAlign.center,
              style: GoogleFonts.rowdies(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: 30,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
