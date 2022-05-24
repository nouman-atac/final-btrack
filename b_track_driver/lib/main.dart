// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, use_key_in_widget_constructors, deprecated_member_use
import 'package:b_track_driver/NavBar.dart';
import 'package:b_track_driver/login.dart';
import 'package:b_track_driver/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'AdminWidget.dart';

void main() {

runApp(MyApp());
} 
final Style = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Color(0xfffb713c),
  fontSize: 18,
));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AdminWidget.cookieSetup();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'B-track Driver',
        theme: ThemeData(scaffoldBackgroundColor: Color(0xfffb713c)),
        home: SplashScreen());
  }
}

class Mainpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    // print(AdminWidget.appDocDir.path);
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.grid_view_rounded),
        //   color: Colors.white,
        //   onPressed: () {
        //     Navigator.of(context)
        //         .push(MaterialPageRoute(builder: (context) => NavBar()));
        //   },
        // ),
        title: Center(
          child: Image.asset(
            'assets/images/logo_name.png',
            height: 60,
            width: 200,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share),
            color: Colors.white,
          )
        ],
        backgroundColor: Color(0xfffb713c),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0),
                  bottomLeft: const Radius.circular(40.0),
                  bottomRight: const Radius.circular(40.0),
                ),

                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 2.0,
                    spreadRadius: 2.0,
                  )
                ],
              ),
              padding: EdgeInsets.only(top: 20),
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              height: 500,
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/Logo.png',
                      height: 200,
                      width: 250,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text(
                        'Please login yourself,\n to access \nthe Driver Services',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lobster(
                            textStyle: TextStyle(
                          color: Color(0xfffb713c),
                          fontSize: 25,
                        ))),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text(
                        "Login",
                        style: GoogleFonts.rowdies(
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => login()));
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(95, 75),
                        primary: Color(0xfffb713c),
                        elevation: 10,
                        shadowColor: Colors.black,
                        shape: const CircleBorder(),
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
