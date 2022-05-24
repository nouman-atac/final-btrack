// ignore_for_file: must_be_immutable

import 'package:client/resources.dart';
import 'package:flutter/material.dart';

class HoverButton extends StatelessWidget {
  HoverButton(
      {Key? key,
      this.width = 100,
      this.height = 40,
      required this.onPressed,
      this.color = MyColors.cobaltBlue,
      this.hoverColor,
      required this.child})
      : super(key: key);

  double width, height;
  final void Function()? onPressed;
  Widget child;
  Color? color, hoverColor;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: this.width,
      height: this.height,
      color: this.color,
      hoverColor:
          this.hoverColor != null ? this.hoverColor : MyColors.grottoBlue,
      child: this.child,
      onPressed: this.onPressed,
    );
  }
}
