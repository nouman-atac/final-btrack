// ignore_for_file: prefer_const_constructors, unused_label

import 'package:b_track_driver/login.dart';
import 'package:flutter/material.dart';

InputDecoration buildInputDecoration() {
  return InputDecoration(
      errorStyle: estyle,
      contentPadding: EdgeInsets.only(left: 25),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Color(0xfffb713c))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Color(0xfffb713c))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Color(0xfffb713c))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white)),
      filled: true,
      fillColor: Colors.white);
}
