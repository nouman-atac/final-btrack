// ignore_for_file: unused_import

import 'package:client/resources.dart';
import 'package:client/viewComponent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final txthstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: MyColors.cobaltBlue,
  fontSize: 30,
));

final txtbstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: MyColors.cobaltBlue,
  fontSize: 20,
));

final btntxtstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.white,
  fontSize: 20,
));

class SubTitleText extends StatelessWidget {
  final String value;
  SubTitleText(this.value, {Key? key}) : super(key: key) {}

  Widget build(BuildContext context) {
    return Text(
      value,
      style: txthstyle,
    );
  }
}

class SideBarLink extends StatelessWidget {
  final String text, link;
  SideBarLink({Key? key, required String this.text, required this.link})
      : super(key: key);

  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.pushNamed(context, this.link),
      hoverColor: MyColors.cobaltBlue,
      child: Container(
          // color: Colors.grey[200],
          width: 225,
          padding: EdgeInsets.fromLTRB(70, 8, 0, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              this.text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                wordSpacing: 2,
                color: Color(0xffE8EEF1),
              ),
            ),
            // child: MaterialButton(
            //   onPressed: ()=>Navigator.pushNamed(context, this.link),
            //   hoverColor: MyColors.cobaltBlue,
            //   child: Text(
            //       this.text,
            //       style: TextStyle(
            //         fontSize:15,
            //         fontWeight: FontWeight.bold,
            //         wordSpacing: 2,
            //       ),
            //     ),
            //   ),
          )),
      // onTap:()=> Navigator.pushNamed(context, this.link),
    );
  }
}

class MediumText extends StatelessWidget {
  MediumText(this.text, {Key? key, this.fontSize = 15}) : super(key: key);

  final double fontSize;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: btntxtstyle,
    );
  }
}
