// ignore_for_file: unused_import, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:js';

import 'package:client/button.dart';
import 'package:dio/dio.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:latlong2/latlong.dart';
// import 'package:mapbox_gl/mapbox_gl.dart' hide LatLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_api/mapbox_api.dart';

import 'package:client/formElement.dart';
import 'package:client/try.dart';
import 'package:client/validate.dart';
import 'textComponent.dart';
import 'resources.dart';
import 'validate.dart';
import 'formElement.dart';
import 'viewComponent.dart';
import 'modules/adminWidget.dart';
import 'modules/drivers.dart';
import 'modules/buses.dart';
import 'modules/busStops.dart';
import 'modules/busRoutes.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final MaterialColor cobaltBlue =
      MaterialColor(0xff343b71, {100: Color(0xff343b71)});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-Track',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff343b71),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => StartPage(),
        "/dashboard": (context) => MyHomePage(),
        // "/driverAddForm":(context)=> DriverForm(),
      },
      // home: MyHomePage(title: 'B-Track'),
    );
  }
}

class DataId {
  static String? driverId;
}
// class TopClass extends InheritedWidget{
//   TopClass
//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) {
// ignore: todo
//     // TODO: implement updateShouldNotify
//     return true;
//   }

// }

class StartPage extends StatefulWidget {
  StartPage({
    Key? key,
  }) : super(key: key);
  // BuildContext context;
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  PageController page = PageController();

  late double width;
  SideMenuDisplayMode displayMode = SideMenuDisplayMode.auto;

  // @override
  //   void initState(){
  //     // this.width=MediaQuery.of(context).size.width;
  //     super.initState();
  //     page.addListener((){
  //       print("Listener Called");
  //       if(MediaQuery.of(context).size.width<1000){
  //         setState((){this.displayMode=SideMenuDisplayMode.compact;});
  //       }
  //       else{
  //           setState((){this.displayMode=SideMenuDisplayMode.open;});
  //       }

  //     });
  //   }

  @override
  Widget build(BuildContext context) {
    this.width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/imageAssets/logo_name.png",
          height: 40,
        ),
        backgroundColor: MyColors.cobaltBlue,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2.0,
                  spreadRadius: 3.0,
                )
              ],
            ),
            padding: EdgeInsets.all(15),
            child: SideBar(
              context: context,
              controller: page,
              width: width,
              displayMode: this.displayMode,
            ),
          ),
          Expanded(
              child: PageView(
            controller: page,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                child: MyHomePage(),
              ),
              // Container(
              //     // child: Center(
              //       // child:BusRouteForm(width: AdminWidget.getWidth(context),)
              //     // ),

              //     // child: Route(),
              // ),
              //1
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                child: DriverLayout(),
              ),
              //2
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                // child: Center(
                child: BusLayout(),
                // ),
              ),
              //3
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                // child: Center(
                child: BusStopLayout(),
                // ),
              ),
              //4
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                child: BusRouteLayout(),
              ),
              //5
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                child: Center(
                  child: SubTitleText("Routes2"),
                ),
              ),
              //6
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                child: Center(
                  child: DriverForm(
                    width: AdminWidget.getWidth(context),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  // final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SubTitleText("Admin Dashboard")],
        ),
        Divider(
          height: 50,
        ),
        SizedBox(
          height: 20,
        ),
        // GridView.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder)

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            for (int index = 0; index < DashBoard.tileData.length; index++)
              DashBoardGridTile(
                  head: DashBoard.tileData[index]['head'],
                  link: DashBoard.tileData[index]['link'],
                  icon: DashBoard.tileData[index]['icon'])
          ],
        )
      ],
    ));
  }
}
