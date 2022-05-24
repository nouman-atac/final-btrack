// ignore_for_file: camel_case_types, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_collection_literals, deprecated_member_use, prefer_final_fields, must_be_immutable, unused_field, library_names, annotate_overrides, unnecessary_null_comparison, dead_code

import 'package:b_track/SuccessfulRegister.dart';
import 'package:b_track/login.dart';
import 'package:b_track/textfieldstyle.dart';
import "package:google_fonts/google_fonts.dart";
import "package:flutter/material.dart";
import 'AdminWidget.dart';

final style = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.white,
  fontSize: 15,
));

final estyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.orangeAccent[700],
  fontSize: 12,
));

final buttonstyle = ElevatedButton.styleFrom(
    fixedSize: Size(150, 40),
    primary: Color(0xff343b71),
    elevation: 15,
    shadowColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: Colors.grey.shade800),
    ));

class register extends StatefulWidget {
  @override
  _register1 createState() => _register1();
}

class _register1 extends State<register> {
  bool _isVisible = false;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  String _errorMessage = '';
  String name = "", email = "", phone = "";
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullName= TextEditingController();
  TextEditingController mobile= TextEditingController();

  TextEditingController userEmail= TextEditingController();

  TextEditingController password= TextEditingController();


  onPasswordChanged(String password) {
    final numbericRegex = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNumber = false;
      if (numbericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
    });
  }

  int _value = 0;
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
          title: Text('Register',
              style: GoogleFonts.rowdies(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ))),
          backgroundColor: Color(0xff343b71),
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Full Name',
                        style: style,
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: TextFormField(
                        controller: fullName,
                        cursorColor: Colors.grey.shade800,
                        keyboardType: TextInputType.text,
                        decoration: buildInputDecoration(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter a Name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value!;
                        },
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Mobile No',
                        style: style,
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 30),
                      child: TextFormField(
                        controller: mobile,
                        cursorColor: Colors.grey.shade800,
                        keyboardType: TextInputType.number,
                        decoration: buildInputDecoration(),
                        validator: (value) {
                          if (value == null || value.length != 10) {
                            return 'Please a Enter valid Number';
                          }
                          return null;
                        },
                      ),
                    )),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Radio(
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.white),
                                  value: 1,
                                  groupValue: _value,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = 1;
                                    });
                                  }),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Male',
                                style: style,
                              )
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(right: 30)),
                          Row(
                            children: [
                              Radio(
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.white),
                                  value: 2,
                                  groupValue: _value,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = 2;
                                    });
                                  }),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Female',
                                style: style,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Email-Id',
                        style: style,
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: TextFormField(
                        controller: userEmail,
                        cursorColor: Colors.grey.shade800,
                        keyboardType: TextInputType.emailAddress,
                        decoration: buildInputDecoration(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter email';
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return 'Please a valid Email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Password',
                        style: style,
                      ),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 20),
                      child: TextFormField(
                        controller: password,
                        cursorColor: Colors.grey.shade800,
                        onChanged: (password) => onPasswordChanged(password),
                        obscureText: !_isVisible,
                        decoration: InputDecoration(
                            errorStyle: estyle,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              icon: _isVisible
                                  ? Icon(
                                      Icons.visibility,
                                      color: Color(0xff343b71),
                                    )
                                  : Icon(Icons.visibility_off,
                                      color: Color(0xff343b71)),
                            ),
                            contentPadding: EdgeInsets.only(left: 25),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.white)),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (value) {
                          if (value == null ||
                              (_isPasswordEightCharacters == false ||
                                  _hasPasswordOneNumber == false)) {
                            return 'Please a Enter Valid Password';
                          }
                          return null;
                        },
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: _isPasswordEightCharacters
                                    ? Colors.white
                                    : Colors.transparent,
                                border: _isPasswordEightCharacters
                                    ? Border.all(color: Colors.transparent)
                                    : Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Color(0xff343b71),
                                size: 15,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Contains at least 8 characters",
                            style: style,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: _hasPasswordOneNumber
                                    ? Colors.white
                                    : Colors.transparent,
                                border: _hasPasswordOneNumber
                                    ? Border.all(color: Colors.transparent)
                                    : Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Color(0xff343b71),
                                size: 15,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Contains at least 1 number",
                            style: style,
                          )
                        ],
                      ),
                    ),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 35),
                      child: ElevatedButton(
                          child: Text("Submit", style: style),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              
                              AdminWidget.dio.post("/user/register",data:{ 
                          "userName": fullName.text,"userEmail":userEmail.text,"mobile":mobile.text,"password":password.text,
                          "gender":_value==1?"Male":"Female"
                          }).then((value){
                          var data =value.data;
                          print(data);
                        
                          if(data['status']==1){
                            // Navigator.push(context, MaterialPageRoute(builder: (builder)=> SelectRoute()));
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          }
                          else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          }
                        }).onError((error, stackTrace) {
                          var snackBar= SnackBar(content: Text(error.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(error.toString());
                        });

                            }
                          },
                          style: buttonstyle),
                    )),
                  ],
                ))));
  }
}
