import 'package:flutter/material.dart';

abstract class DashBoard {
  static List<Map> tileData = [
    {
      "head": "Drivers",
      "link": "/driverAddForm",
      "icon": "driver.png",
    },
    {
      "head": "Bus Stops",
      "link": "/b",
      "icon": "busStop.png",
    },
    {
      "head": "Buses",
      "link": "/b",
      "icon": "bus.png",
    },
    {
      "head": "Routes",
      "link": "/b",
      "icon": "route.png",
    },
  ];
}

abstract class MyColors {
  static const cobaltBlue = Color(0xff343b71);
  static const navyBlue = Color(0xff1E3D58);
  static const royalBlue = Color(0xff057DCD);
  static const grottoBlue = Color(0xff43b0f1);
  static const bWhite = Color(0xffe8eef1);
  static const lineGrey = Color(0xffE8E8E8);
  static const lightGrey = Color(0xffd3d3d3);
  static const silver = Color(0xffc0c0c0);
  static const veryDarkGrey = Color(0xff303030);
  static const failure = Color(0xffbb2124);
  static const success = Color(0xff22bb33);
}
