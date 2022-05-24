// ignore_for_file: unused_import, must_be_immutable, must_call_super, body_might_complete_normally_nullable

import 'dart:async';

import 'package:client/button.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:client/formElement.dart';
import 'package:client/validate.dart';
import '../textComponent.dart';
import '../resources.dart';
import '../validate.dart';
import '../viewComponent.dart';
import 'adminWidget.dart';

class DataId {
  static String? driverId;
}

class BusForm extends StatefulWidget {
  // mode    1= Add    2= Edit
  static const String route = '/driverAddForm';
  BusForm(
      {Key? key,
      int this.mode = 1,
      required this.width,
      this.id,
      this.showDriverList})
      : super(key: key);
  double width;
  String? id;
  void Function()? showDriverList;
  final int mode;
  @override
  State<BusForm> createState() => _BusForm();
}

class _BusForm extends State<BusForm> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  // Key
  PageController pageController = PageController();
  var currentTime = DateTime(2022);

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));

  Map<String, dynamic> data = {"busRegistrationNumber": "", "mode": 0};

  void initState() {
    if (widget.id != null) {
      dio
          .get(
              "/admin/api/getBus?id=${widget.id == null ? DataId.driverId : widget.id}")
          .then((result) {
        print(result.data['data']['busRegistrationNumber']);
        if (result.data["status"] == 0) {
          setState(() {
            this.messageText = "Bus data is not available";
            this.messageContainerColor = MyColors.failure;
            this.messageContainerHeight = 40.0;
            this.messageCancelIconSize = 15.0;
          });
        } else {
          setState(() {
            this.data = result.data['data'];
            this.data['mode'] = 1;
          });
        }
      }, onError: (err) {
        print(err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Container(
                    // padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                    // color: Colors.white54,
                    width: widget.width - 0.3 * widget.width,
                    alignment: Alignment.center,
                    // height: 20,
                    // color: Colors.grey,
                    child: Form(
                        key: _globalKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: this.messageContainerHeight,
                                width: widget.width,
                                color: this.messageContainerColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                      child: MediumText(
                                        this.messageText,
                                        fontSize: 15,
                                      ),
                                    ),
                                    IconButton(
                                        iconSize: this.messageCancelIconSize,
                                        onPressed: () {
                                          setState(() {
                                            this.messageText = "";
                                            this.messageContainerHeight = 0.0;
                                            this.messageContainerColor = null;
                                            this.messageCancelIconSize = 0.0;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.grey.shade300,
                                        ))
                                  ],
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: widget.showDriverList,
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              MyColors.cobaltBlue),
                                      elevation:
                                          MaterialStateProperty.all(20.0),
                                    ),
                                    child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 10, 15, 10),
                                        child: MediumText("Bus List")))
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SizedBox(width: 20,),
                                SubTitleText(this.data['mode'] == 0
                                    ? "Add Bus"
                                    : "Update Bus")
                              ],
                            ),
                            Divider(
                              height: 50,
                            ),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "Bus Registration Number",
                                initialValue: this
                                    .data['busRegistrationNumber']
                                    .toString(),
                                onChanged: (value) {
                                  this.data['busRegistrationNumber'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a Number';
                                  }
                                  return null;
                                },
                              ),
                              // MyTextFormField(fieldName: "Last Name", initialValue:this.data['lastName'],onChanged: (value){this.data['lastName']=value;},validator:(value)=>null),
                            ]),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_globalKey.currentState!.validate()) {
                                      print("Validated");

                                      print(this.data);
                                      try {
                                        // this.data.remove("driverImage");
                                        // this.data['driverImage']=this.data["driverImage"]
                                        // var temp = this.data["driverImage"]["imageBytes"];
                                        // this.data["driverImage"]["imageBytes"]= ;
                                        await dio
                                            .post(
                                                this.data['mode'] == 0
                                                    ? "/admin/api/addBus"
                                                    : "/admin/api/updateBus",
                                                data:FormData.fromMap(this.data),
                                                options: Options(
                                                    contentType:
                                                        'multipart/form-data',
                                                    headers: {
                                                      Headers.contentLengthHeader:
                                                          this.data.length,
                                                    }))
                                            .then((response) {
                                          late String msg;
                                          // late int status;
                                          late Color color;
                                          print(response.data['status']);
                                          if (response.data['status'] == 0) {
                                            //input error
                                            msg = response.data['errors'];
                                            color = MyColors.failure;
                                            // this.messageContainerHeight=20.0;

                                          } else if (response.data['status'] ==
                                              1) {
                                            // success
                                            msg = response.data['msg'];
                                            color = MyColors.success;
                                            // this.messageContainerHeight=20.0;

                                          } else if (response.data['status'] ==
                                              2) {
                                            // code error
                                            msg = response.data['msg'];
                                            color = MyColors.failure;
                                            // this.messageContainerHeight=20.0;

                                          }
                                          setState(() {
                                            this.messageText = msg;
                                            this.messageContainerColor = color;
                                            this.messageContainerHeight = 40.0;
                                            this.messageCancelIconSize = 15.0;
                                          });
                                          print(this.messageText);
                                        });

                                        // print(response['status']);
                                        // if(response['status']==0)
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        MyColors.cobaltBlue),
                                    elevation: MaterialStateProperty.all(20.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Text(
                                      "Submit",
                                      style: btntxtstyle,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Divider(
                              height: 3,
                            ),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        ))))
          ],
        ),
      ),
    );
  }
}

class BusDataTable extends StatefulWidget {
  BusDataTable({Key? key, required this.width, this.addDriver, this.editBus})
      : super(key: key);
  double width;
  void Function()? addDriver;
  var editBus;

  @override
  _BusDataTableState createState() => _BusDataTableState();
}

class _BusDataTableState extends State<BusDataTable> {
  PageController page = PageController();
  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));
  var rows = null;

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  @override
  void initState() {
    super.initState();
    dio.get("/admin/api/getBuses").then((value) {
      print(value.data['data'].runtimeType);
      setState(() {
        this.rows = value.data['data'];
      });
    });
  }

  List<DataRow> _getRows(BuildContext context, List<dynamic>? data) {
    var newdata = data != null
        ? data
        : [
            {
              "busId": "",
              "busRegistrationNumber": "",
              "currentLocation": '',
              "currentRoute": "",
              "createdBy": "",
              "createdOn": "",
            }
          ];

    // if(newdata.length==0)
    // return [DataRow(cells: [
    //   DataCell(Text("No Data about drivers Present"))
    // ])];
    // print(newdata);

    return newdata.map((bus) {
      return DataRow(cells: [
        DataCell(Text(
          bus['busRegistrationNumber'].toString(),
          style: txtbhstyle,
        )),
        DataCell(Text(
          bus['createdBy'].toString(),
          style: txtbhstyle,
        )),
        // DataCell(Text(dbusiver['dateOfBirth'].toString())),

        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.edit),
          onPressed: widget.editBus(bus['busId']),
        )),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.delete),
          onPressed: () {
            // if(driver['driverId']==null) return;
            dio.delete('/admin/api/deleteBus?id=${bus['busId']}').then((value) {
              print(value.data);
              if (value.data['status'] == 1) {
                print(value.data);
                dio.get("/admin/api/getBuses").then((value) {
                  print(value.data['data'].runtimeType);
                  setState(() {
                    this.messageText = "Delete Successful";
                    this.messageContainerHeight = 40.0;
                    this.messageContainerColor = MyColors.success;
                    this.messageCancelIconSize = 15.0;
                    this.rows = value.data['data'];
                  });
                });
              }
            }).onError((error, stackTrace) {
              setState(() {
                this.messageText =
                    "Client Error has occured. Please contact Admin";
                this.messageContainerHeight = 40.0;
                this.messageContainerColor = MyColors.failure;
                this.messageCancelIconSize = 15.0;
                // this.rows=value.data['data'];
              });
            });
          },
        )),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // _getDriverData();
    // var rows=_getRows();
    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
          child: Container(
            width: widget.width * 0.9,
            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: Expanded(
              child: Column(
                children: [
                  Container(
                      height: this.messageContainerHeight,
                      width: widget.width,
                      color: this.messageContainerColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: MediumText(
                              this.messageText,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                              iconSize: this.messageCancelIconSize,
                              onPressed: () {
                                setState(() {
                                  this.messageText = "";
                                  this.messageContainerHeight = 0.0;
                                  this.messageContainerColor = null;
                                  this.messageCancelIconSize = 0.0;
                                });
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.grey.shade300,
                              ))
                        ],
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(width: 20,),
                      SubTitleText("Add Bus")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: widget.addDriver,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(MyColors.cobaltBlue),
                            elevation: MaterialStateProperty.all(20.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: MediumText("Add Bus")))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      // width: widget.width,
                      alignment: Alignment.bottomLeft,
                      child: SingleChildScrollView(
                        // physics: ScrollPhysics.horizontal,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(columns: [
                          DataColumn(
                              label: Text(
                            "Bus Registration",
                            style: txtbhstyle,
                          )),
                          DataColumn(
                              label: Text("Created By", style: txtbhstyle)),
                          DataColumn(label: Text("Update", style: txtbhstyle)),
                          DataColumn(label: Text("Delete", style: txtbhstyle)),
                        ], rows: _getRows(context, this.rows)),
                      ))
                ],
              ),
            ),
          )),
    );
  }
}

class BusLayout extends StatefulWidget {
  const BusLayout({Key? key}) : super(key: key);

  @override
  State<BusLayout> createState() => _BusLayoutState();
}

class _BusLayoutState extends State<BusLayout> {
  int mode = 0;
  String? id;

  void Function()? showDriverList() {
    setState(() {
      this.mode = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints boxContraints) {
      if (this.mode == 1) {
        this.id = null;
        return BusForm(
          width: AdminWidget.getWidth(context),
          showDriverList: () {
            setState(() {
              this.mode = 0;
            });
          },
        );
      } else if (this.mode == 2) {
        return BusForm(
            width: AdminWidget.getWidth(context),
            id: this.id,
            showDriverList: () {
              setState(() {
                this.mode = 0;
              });
            });
      } else {
        return BusDataTable(
            width: AdminWidget.getWidth(context),
            addDriver: () {
              setState(() {
                this.mode = 1;
              });
            },
            editBus: (String id) => () {
                  // if(id==id||id.isEmpty) return;
                  setState(() {
                    this.mode = 2;
                    this.id = id;
                  });
                });
      }
    });
  }
}
