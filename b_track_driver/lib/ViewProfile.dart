// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, file_names

import 'package:b_track_driver/AdminWidget.dart';
import 'package:b_track_driver/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  String name,email,mobile;
  ProfilePage({Key? key,required this.name,required this.email,required this.mobile}):super(key: key);
  
  Widget textfield({@required hintText}) {
    return Material(
      elevation: 15,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
            hintText: hintText,
            enabled: false,
            hintStyle: TextStyle(
              letterSpacing: 2,
              color: Color.fromARGB(255, 109, 109, 109),
              fontWeight: FontWeight.bold,
            ),
            fillColor: Colors.white30,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AdminWidget.dio.get("/driver/api/").then(((value) {
      var data = value.data;
      if(data['status']==-1){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>login(msg: "Session Expired Please log in first ",)));
      }
    }));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('My Profile',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3))
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-fff2lftqIE077pFAKU1Mhbcj8YFvBbMvpA&usqp=CAU'))),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
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
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(15),
                height: 450,
                width: double.infinity,
                //margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Name: ",
                          style: GoogleFonts.rowdies(
                              textStyle: TextStyle(
                            color: Color(0xfffb713c),
                            fontSize: 18,
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        textfield(
                          hintText: name,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          "Email ID: ",
                          style: GoogleFonts.rowdies(
                              textStyle: TextStyle(
                            color: Color(0xfffb713c),
                            fontSize: 18,
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        textfield(
                          hintText: email,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          "Mobile No: ",
                          style: GoogleFonts.rowdies(
                              textStyle: TextStyle(
                            color: Color(0xfffb713c),
                            fontSize: 18,
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        textfield(
                          hintText: mobile,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
