import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class AdminWidget extends InheritedWidget{
  Key? key;
  Widget child;
  AdminWidget({this.key,required this.child}):super(key: key,child: child);
  static String url="http://7629-2401-4900-172b-1350-8995-f80b-a081-108f.ngrok.io";
  static Dio dio=Dio(BaseOptions(baseUrl: url));
  static late Directory appDocDir;
  static late PersistCookieJar cookieJar;
  

  static void cookieSetup()async{
    appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    cookieJar=PersistCookieJar(storage:FileStorage(appDocPath+"/.cookies/"));
    dio.interceptors.add(CookieManager(cookieJar));

  }
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    throw UnimplementedError();
  }
  
  static Dio getDio()=> dio;
}