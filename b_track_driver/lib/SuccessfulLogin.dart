// ignore_for_file: camel_case_types, use_key_in_widget_constructors, prefer_const_constructors, file_names, prefer_final_fields, unused_field, unused_element, annotate_overrides

import 'package:b_track_driver/login.dart';
import 'package:b_track_driver/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class successpage2 extends StatefulWidget {
  @override
  _successpage2 createState() => _successpage2();
}

class _successpage2 extends State<successpage2> {
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => GetBus())));
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
        title: Text('Login',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                height: 400,
                padding: EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Color(0xfffb713c),
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/images/Success.png",
                    height: 220, width: 220)),
            SizedBox(height: 20),
            Text(
              "Login\nSuccessfully!",
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
