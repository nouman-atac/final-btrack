// ignore_for_file: camel_case_types, prefer_const_constructors, use_key_in_widget_constructors, unnecessary_type_check, unrelated_type_equality_checks

import 'package:b_track/SuccessfulLogin.dart';
import 'package:b_track/homepage.dart';
import 'package:b_track/textfieldstyle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:b_track/registration.dart';
import 'AdminWidget.dart';

class login extends StatefulWidget {
  @override
  _login createState() => _login();
}

class _login extends State<login> {
  bool _isVisible = false;
  final _formKey = GlobalKey<FormState>();

    TextEditingController userEmail= TextEditingController();

  TextEditingController password= TextEditingController();

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
        title: Text('Login',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xff343b71),
        elevation: 0,
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 100.0),
                child: Text(
                  'Mobile no / Email-Id',
                  style: style,
                ),
              )),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                    controller: userEmail,
                    cursorColor: Colors.grey.shade800,
                    decoration: buildInputDecoration(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Mobile no / Email-Id';
                      }
                      if (value == num.tryParse(value) && value.length != 10) {
                        return 'Please Enter valid Mobile no';
                      } else if (value is String &&
                          !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                        return 'Please Enter valid Email';
                      }
                      return null;
                    }),
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                    controller: password,
                    cursorColor: Colors.grey.shade800,
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
                      if (value == null || value.isEmpty) {
                        return 'Incorrect password';
                      }
                      return null;
                    }),
              )),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ElevatedButton(
                    child: Text("Login", style: style),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                       
                       AdminWidget.dio.post("/user/login",data:{ 
                          "userEmail": userEmail.text, "password": password.text 
                          }).then((value){
                          var data =value.data;
                          print(data);
                          if(data['authenticated']==true){
                            // print("Cookies");
                            AdminWidget.cookieJar.loadForRequest(Uri.parse(AdminWidget.url)).then((cookie) {
                              print("Cookies: ${cookie}");
                              
                              var snackBar= SnackBar(content: Text(data['msg']));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => successpage2()));
                            });
                            
                          }
                          else{
                            var snackBar= SnackBar(content: Text(data['msg']));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          )),
    );
  }
}
