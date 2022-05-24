import 'package:flutter/material.dart';

class AdminWidget extends InheritedWidget{

  AdminWidget({required Widget child}):super(child: child){
    
  }

  // late final double width;

  static double getWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}