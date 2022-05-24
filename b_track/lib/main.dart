// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, duplicate_ignore, unused_import, avoid_unnecessary_containers, non_constant_identifier_names, deprecated_member_use, unused_local_variable, unnecessary_new, import_of_legacy_library_into_null_safe, unnecessary_import, prefer_collection_literals
import 'package:b_track/BusNoSearch.dart';
import 'package:b_track/NavBar.dart';
import 'package:b_track/homepage.dart';
import 'package:b_track/login.dart';
import 'package:b_track/registration.dart';
import 'package:b_track/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:b_track/AdminWidget.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(MyApp());
  
}

final Style = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Color(0xff343b71),
  fontSize: 18,
));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      AdminWidget.cookieSetup();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'B-track',
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff343b71)),
      home: SplashScreen(),
    );
  }
}

class Mainpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.grid_view_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NavBar()));
            },
          ),
          title: Center(
            child: Image.asset(
              'assets/images/logo_name.png',
              height: 60,
              width: 200,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                
                // Navigator.of(context)
                //   .push(MaterialPageRoute(builder: (context) => RealTimeLocation()));
              },
              icon: Icon(Icons.share),
              color: Colors.white,
            )
          ],
          backgroundColor: Color(0xff343b71),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                padding: EdgeInsets.only(top: 20),
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                height: 430,
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 200,
                      ),
                    ),
                    Center(
                      child: Text(
                          'Wellcome to B-Track,\n we\'re tracking\n real time Bus location.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lobster(
                              textStyle: TextStyle(
                            color: Color(0xff343b71),
                            fontSize: 25,
                          ))),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Text(
                        'To use it smoothly,\n please Register here',
                        textAlign: TextAlign.center,
                        style: Style,
                      ),
                    ),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: ElevatedButton(
                        child: Text(
                          "Register",
                          style: GoogleFonts.rowdies(
                            textStyle: TextStyle(fontSize: 20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => register()));
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(150, 40),
                          primary: Color(0xff343b71),
                          elevation: 10,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ))
                  ],
                )),
            Container(
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                    bottomLeft: const Radius.circular(40.0),
                    bottomRight: const Radius.circular(40.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        'OR\n if you already\n registered ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rowdies(
                            textStyle: TextStyle(
                          color: Color(0xff343b71),
                          fontSize: 18,
                        )),
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        '→',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rowdies(
                            textStyle: TextStyle(
                          color: Color(0xff343b71),
                          fontSize: 50,
                        )),
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: ElevatedButton(
                        child: Text(
                          "Login",
                          style: GoogleFonts.rowdies(
                            textStyle:
                                TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => login()));
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(95, 75),
                          primary: Color(0xff343b71),
                          elevation: 10,
                          shadowColor: Colors.black,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ))
                  ],
                ))
          ],
        ));
  }
}
