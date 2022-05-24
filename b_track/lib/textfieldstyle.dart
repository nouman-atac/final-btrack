// ignore_for_file: prefer_const_constructors

import 'package:b_track/registration.dart';
import 'package:flutter/material.dart';

InputDecoration buildInputDecoration() {
  return InputDecoration(
      errorStyle: estyle,
      contentPadding: EdgeInsets.only(left: 25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white)),
      filled: true,
      fillColor: Colors.white);
}
