// ignore_for_file: unused_import, must_be_immutable

import 'package:client/button.dart';
import 'package:client/resources.dart';
import 'package:client/textComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class FormRow extends StatelessWidget {
  FormRow({Key? key, required this.children}) : super(key: key);

  // final BuildContext context;
  final List<Widget> children;

  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraint) {
      if (MediaQuery.of(context).size.width > 700)
        return Wrap(
          direction: Axis.vertical,
          children: [
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: this.children,
            ),
          ],
        );
      else
        return Wrap(direction: Axis.vertical, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: this
                .children
                .map((e) => Wrap(
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        e
                      ],
                    ))
                .toList(),
          ),
        ]);
    });
  }
}

final txtbhstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: MyColors.cobaltBlue,
  fontSize: 17,
));

final txtfstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.grey.shade600,
  fontSize: 16,
));

final etxtstyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.red.shade300,
  fontSize: 14,
));

class MyTextFormField extends StatelessWidget {
  MyTextFormField(
      {Key? key,
      required this.fieldName,
      required this.validator,
      this.onChanged,
      this.readOnly = false,
      this.initialValue})
      : super(key: key);

  final String fieldName;
  String? initialValue;
  bool? readOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  late double width;
  late TextEditingController _controller;

  Widget build(BuildContext context) {
    if (this.initialValue != null && !this.initialValue!.isEmpty)
      _controller = TextEditingController(text: this.initialValue);
    else
      _controller = TextEditingController();

    if (MediaQuery.of(context).size.width < 700)
      this.width = 0.8 * MediaQuery.of(context).size.width;
    else if (MediaQuery.of(context).size.width < 1400)
      this.width = 0.4 * MediaQuery.of(context).size.width;
    else
      this.width = 500;

    return Container(
      width: this.width,
      // margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
      // padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            // width: 00,
            child: Text(
              fieldName + ":",
              style: txtbhstyle,
            ),
          ),
          // Divider(thickness: 5,),
          SizedBox(
            height: 7,
          ),
          Container(
              width: this.width - 50,
              // height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2.0,
                    spreadRadius: 3.0,
                  )
                ],
              ),
              child: Material(
                child: TextFormField(
                    controller: _controller,
                    cursorColor: MyColors.cobaltBlue,
                    cursorHeight: 20,
                    style: txtfstyle,

                    // initialValue: this.initialValue,
                    decoration: InputDecoration(
                        errorBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        errorStyle: etxtstyle,
                        contentPadding: EdgeInsets.only(left: 25),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.cobaltBlue, width: 3),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyColors.cobaltBlue, width: 3)),
                        filled: true,
                        fillColor: Colors.white),
                    validator: validator,
                    onChanged: onChanged,
                    readOnly: this.readOnly!),
              ))
        ],
      ),
    );
  }
}

class UploadFileButton extends StatelessWidget {
  UploadFileButton(
      {Key? key,
      required this.fieldName,
      this.fileName = "",
      required this.onPressed})
      : super(key: key);

  final String fieldName;
  String fileName;
  final void Function()? onPressed;
  late double width;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700)
      this.width = 0.8 * MediaQuery.of(context).size.width;
    else if (MediaQuery.of(context).size.width < 1400)
      this.width = 0.4 * MediaQuery.of(context).size.width;
    else
      this.width = 500;

    return Container(
        width: this.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              // width: 00,
              child: Text(
                fieldName + ":",
                style: txtbhstyle,
              ),
            ),
            // Divider(thickness: 5,),
            SizedBox(
              height: 20,
            ),
            Container(
                alignment: Alignment.center,
                width: this.width - 50,
                // height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HoverButton(
                      onPressed: onPressed,
                      width: 150,
                      height: 50,
                      color: MyColors.cobaltBlue,
                      hoverColor: Color.fromARGB(255, 66, 72, 115),
                      child: MediumText(
                        "Upload",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      this.fileName,
                      style: txtbhstyle,
                    ),
                  ],
                ))
          ],
        ));
  }
}

class CalendarInput extends StatelessWidget {
  CalendarInput(
      {Key? key,
      required this.onPressed,
      required this.fieldName,
      required this.currentDate,
      required this.validator,
      required this.hintValue})
      : super(key: key);

  double width = 500;
  final String fieldName;
  String hintValue;
  final VoidCallback onPressed;
  String? Function(String?)? validator;
  String currentDate;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700)
      this.width = 0.8 * MediaQuery.of(context).size.width;
    else if (MediaQuery.of(context).size.width < 1400)
      this.width = 0.4 * MediaQuery.of(context).size.width;
    else
      this.width = 500;

    return Container(
        // decoration: BoxDecoration(border: Border.all(width: 1)),
        width: this.width,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              // width: 00,
              child: Text(
                fieldName + ":",
                style: txtbhstyle,
              ),
            ),
            SizedBox(
              height: 7,
            ),
            Container(
              width: this.width - 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2.0,
                    spreadRadius: 3.0,
                  )
                ],
              ),
              // height: 50,
              // decoration: BoxDecoration(
              //   border: Border.all(width: 1)
              // ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  width: this.width - 100,
                  child: Material(
                    elevation: 2,
                    shadowColor: MyColors.lightGrey,
                    child: TextFormField(
                      style: txtfstyle,
                      onTap: this.onPressed,
                      decoration: InputDecoration(
                          errorBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          errorStyle: etxtstyle,
                          contentPadding: EdgeInsets.only(left: 25),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyColors.cobaltBlue, width: 3),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyColors.cobaltBlue, width: 3)),
                          filled: true,
                          fillColor: Colors.white),
                      validator: this.validator,
                      readOnly: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: this.onPressed,
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      size: 25,
                      color: MyColors.veryDarkGrey,
                    ))
              ]),
            )
          ],
        ));
  }
}

class MyDropDownFormField extends StatelessWidget {
  MyDropDownFormField(
      {Key? key,
      required this.fieldName,
      required this.items,
      required this.validator,
      required this.onChanged,
      this.initialValue})
      : super(key: key);

  final String fieldName;
  final String? Function(String?)? validator;
  late double width;
  String? initialValue;
  // List<DropdownMenuItem<String>> items;
  List<DropdownMenuItem<dynamic>> items;
  final void Function(dynamic)? onChanged;

  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700)
      this.width = 0.8 * MediaQuery.of(context).size.width;
    else if (MediaQuery.of(context).size.width < 1400)
      this.width = 0.4 * MediaQuery.of(context).size.width;
    else
      this.width = 500;

    return Container(
      width: this.width,
      // margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
      // padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            // width: 00,
            child: Text(
              fieldName + ":",
              style: txtbhstyle,
            ),
          ),
          // Divider(thickness: 5,),
          SizedBox(
            height: 7,
          ),
          Container(
              width: this.width - 50,
              // height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2.0,
                    spreadRadius: 3.0,
                  )
                ],
              ),
              child: Material(
                  elevation: 2,
                  shadowColor: MyColors.silver,
                  child: DropdownButtonFormField(
                      style: txtfstyle,
                      // elevation: 2,
                      value: this.initialValue,
                      hint: DropdownMenuItem(
                        value: "",
                        child: Text("Select", textAlign: TextAlign.center),
                      ),
                      decoration: InputDecoration(
                          errorBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          errorStyle: etxtstyle,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyColors.cobaltBlue, width: 3),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyColors.cobaltBlue, width: 3)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsets.only(left: 20, top: 10, right: 20)),
                      items: items,
                      onChanged: this.onChanged)))
        ],
      ),
    );
  }
}
