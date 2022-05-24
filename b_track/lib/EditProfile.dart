// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfile createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  bool isObscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Edit Profile',
              style: GoogleFonts.rowdies(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ))),
          backgroundColor: Color(0xff343b71),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.0,
                spreadRadius: 3.0,
              )
            ],
          ),
          padding: EdgeInsets.only(left: 15, top: 20, right: 15),
          margin: EdgeInsets.all(15),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 4, color: Color(0xff343b71)),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.3))
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/images/male.png'))),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                buildTextField("Full name", "Hello", false),
                buildTextField('Email', 'example@gmail.com', false),
                buildTextField('Mobile no', '8965234170', false),
                buildTextField('Password', '*********', true),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(130, 40),
                            primary: Color(0xff343b71),
                            elevation: 15,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade800),
                            )),
                        child: Text(
                          'Cencel',
                          style: GoogleFonts.rowdies(
                              textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                        )),
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(130, 40),
                            primary: Color(0xff343b71),
                            elevation: 15,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade800),
                            )),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.rowdies(
                              textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                        ))
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: TextField(
        style: GoogleFonts.rowdies(
            textStyle: TextStyle(
          color: Color.fromARGB(255, 109, 109, 109),
          fontSize: 15,
        )),
        cursorColor: Color.fromARGB(255, 109, 109, 109),
        obscureText: isPasswordTextField ? isObscurePassword : false,
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff343b71))),
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscurePassword = !isObscurePassword;
                      });
                    },
                    icon: Icon(
                      Icons.visibility,
                      color: Colors.grey,
                    ))
                : null,
            contentPadding: EdgeInsets.only(bottom: 5),
            labelText: labelText,
            labelStyle: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Color(0xff343b71),
              fontSize: 25,
            )),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey)),
      ),
    );
  }
}
