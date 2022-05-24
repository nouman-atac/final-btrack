// ignore_for_file: unused_import, must_be_immutable, must_call_super, body_might_complete_normally_nullable

import 'dart:async';
import 'dart:io';
import 'dart:js';
import 'package:client/formElement.dart';
import 'package:client/try.dart';
import 'package:client/validate.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../textComponent.dart';
import '../resources.dart';
import '../validate.dart';
import 'package:dio/dio.dart';
import '../viewComponent.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'adminWidget.dart';

class DataId {
  static String? driverId;
}

class DriverForm extends StatefulWidget {
  // mode    1= Add    2= Edit
  static const String route = '/driverAddForm';
  DriverForm(
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
  State<DriverForm> createState() => _DriverForm();
}

class _DriverForm extends State<DriverForm> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  // Key
  PageController pageController = PageController();
  var currentTime = DateTime(2022);

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));

  Map<String, dynamic> data = {
    "dateOfBirth": "dd/mm/yyyy",
    "mode": 0,
    "firstName": "",
    "lastName": "",
    "driverEmail": "",
    "driverMobile": "",
    "driverLicenseNumber": "",
    "address": "",
    "landmark": "",
    "country": "India",
    "state": "Maharashtra",
    "city": "Mumbai",
    "pincode": "",
    "driverImage": <String, dynamic>{
      "imageName": "The image should be under 1 MB (i.e 1024kB).",
      "imageBytes": ""
    },
  };

  void initState() {
    if (widget.id != null || DataId.driverId != null) {
      dio
          .get(
              "/admin/api/getDriver?id=${widget.id == null ? DataId.driverId : widget.id}")
          .then((result) {
        print(result.data['data']['firstName']);
        if (result.data["status"] == 0) {
          setState(() {
            this.messageText = "Driver data is not available";
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

  Future<void> _selectDate(BuildContext context, String field) async {
    await DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(1900, 1, 1),
        maxTime: DateTime.now(), onChanged: (date) {
      // print('change $date');
    }, onConfirm: (date) {
      // var format=DateFormat("dd/mm/YYYY");
      setState(() {
        this.data[field] =
            "${date.day.toString()}/${date.month.toString().padLeft(2, "0")}/${date.year.toString()}";
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future<void> _selectFile(String file) async {
    var result = await FilePickerWeb.platform.pickFiles(type: FileType.image);
    if (result != null) {
      // print(result.files.single.readStream.toString());
      // print(result.files.single.bytes);
      this.data[file]["imageBytes"] =
          result.files.single.bytes!.toList().join(",");

      // this.data[file]["imageBytes"] = http.MultipartFile.fromBytes('file', result.files.single.bytes!.toList(),
      //     contentType: new MediaType('application', 'octet-stream'),
      //     filename: "text_upload.txt")
      // await File.fromRawPath(result.files.single.bytes!);
      setState(() {
        this.data[file]["imageName"] = result.files.single.name;
      });
    } else {
      print("Not Picked");
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        child: MediumText("Driver List")))
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
                                    ? "Add Driver"
                                    : "Update Driver ${this.data['driverEmail']}")
                              ],
                            ),
                            Divider(
                              height: 50,
                            ),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "First Name",
                                initialValue: this.data['firstName'].toString(),
                                onChanged: (value) {
                                  this.data['firstName'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a First Name';
                                  }
                                  return null;
                                },
                              ),
                              MyTextFormField(
                                fieldName: "Last Name",
                                initialValue: this.data['lastName'],
                                onChanged: (value) {
                                  this.data['lastName'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a Last Name';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "Email",
                                initialValue: this.data['driverEmail'],
                                onChanged: (value) {
                                  this.data['driverEmail'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter email';
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return 'Please a valid Email';
                                  }
                                  return null;
                                },
                              ),
                              MyTextFormField(
                                fieldName: "Mobile No",
                                initialValue:
                                    this.data['driverMobile'].toString(),
                                onChanged: (value) {
                                  this.data['driverMobile'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.length != 10) {
                                    return 'Please a Enter valid Number';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                            FormRow(
                              children: [
                                CalendarInput(
                                    onPressed: () {
                                      _selectDate(context, "dateOfBirth");
                                    },
                                    fieldName: "Date of Birth",
                                    currentDate: DateTime.now().toString(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Select Date of Birth';
                                      }
                                      return null;
                                    },
                                    hintValue:
                                        this.data["dateOfBirth"].toString()),
                                MyTextFormField(
                                  fieldName: "License Number",
                                  initialValue:
                                      this.data['driverLicenseNumber'],
                                  onChanged: (value) {
                                    this.data['driverLicenseNumber'] = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter a Valid License Number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "Address",
                                initialValue: this.data['address'],
                                onChanged: (value) {
                                  this.data['address'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a Address';
                                  }
                                  return null;
                                },
                              ),
                              MyTextFormField(
                                fieldName: "Landmark",
                                initialValue: this.data['landmark'],
                                onChanged: (value) {
                                  this.data['landmark'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a Landmark';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                            FormRow(children: [
                              MyDropDownFormField(
                                  fieldName: "Country",
                                  initialValue: this.data['country'],
                                  items: [
                                    ["India", "India"]
                                  ].map<DropdownMenuItem<dynamic>>(
                                      (List<String> newValue) {
                                    return DropdownMenuItem(
                                      value: newValue[0],
                                      child: Text(newValue[1].toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    this.data['country'] = value;
                                  },
                                  validator: (String? value) {
                                    if (value == null || value == "")
                                      return "Please Select SomeThing";

                                    return null;
                                  }),
                              MyDropDownFormField(
                                  fieldName: "State",
                                  initialValue: this.data['state'],
                                  items: [
                                    ["Maharashtra", "Maharashtra"],
                                    ["Uttar Pradesh", "Uttar Pradesh"],
                                    ["Goa", "Goa"],
                                    ["Delhi", "Delhi"]
                                  ].map<DropdownMenuItem<dynamic>>(
                                      (List<String> newValue) {
                                    return DropdownMenuItem(
                                      value: newValue[0],
                                      child: Text(newValue[1].toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    this.data['state'] = value;
                                  },
                                  validator: (String? value) {
                                    if (value == null || value == "")
                                      return "Please Select SomeThing";
                                    return null;
                                  }),
                            ]),
                            FormRow(children: [
                              MyDropDownFormField(
                                  fieldName: "City",
                                  initialValue: this.data['city'],
                                  items: [
                                    ["Mumbai", "Mumbai"],
                                    ["Pune", "Pune"],
                                    ["Panvel", "Panvel"],
                                    ["Thane", "Thane"]
                                  ].map<DropdownMenuItem<dynamic>>(
                                      (List<String> newValue) {
                                    return DropdownMenuItem(
                                      value: newValue[0],
                                      child: Text(newValue[1].toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    this.data['city'] = value;
                                  },
                                  validator: (String? value) {
                                    if (value == null || value == "")
                                      return "Please Select SomeThing";
                                    return null;
                                  }),
                              MyTextFormField(
                                fieldName: "Pincode",
                                initialValue: this.data['pincode'],
                                onChanged: (value) {
                                  this.data['pincode'] = value;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length != 6) {
                                    return 'Please Enter a Valid Pincode';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                            SizedBox(
                              height: 30,
                            ),
                            FormRow(
                              children: [
                                UploadFileButton(
                                    fieldName: "Driver Image",
                                    fileName: this.data["driverImage"]
                                        ["imageName"],
                                    onPressed: () {
                                      _selectFile("driverImage");
                                    })
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_globalKey.currentState!.validate()) {
                                      print("Validated");

                                      // print(this.data);
                                      try {
                                        // this.data.remove("driverImage");
                                        // this.data['driverImage']=this.data["driverImage"]
                                        // var temp = this.data["driverImage"]["imageBytes"];
                                        // this.data["driverImage"]["imageBytes"]= ;
                                        late String routeUrl;
                                        if (this.data['mode'] == 1)
                                          routeUrl = "/admin/api/updateDriver";
                                        else
                                          routeUrl = "/admin/api/addDriver";
                                        await dio
                                            .post(routeUrl,
                                                data:
                                                    FormData.fromMap(this.data),
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
                                    child: Text("Submit", style: btntxtstyle),
                                  ),
                                ),
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

class DriverDataTable extends StatefulWidget {
  DriverDataTable(
      {Key? key, required this.width, this.addDriver, this.editDriver})
      : super(key: key);
  double width;
  void Function()? addDriver;
  var editDriver;

  @override
  _DriverDataTableState createState() => _DriverDataTableState();
}

class _DriverDataTableState extends State<DriverDataTable> {
  PageController page = PageController();
  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));
  var rows = null;

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  @override
  void initState() {
    super.initState();
    dio.get("/admin/api/getDrivers").then((value) {
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
              "driverEmail": "data",
              "firstName": "No",
              "lastName": "driver",
              "driverMobile": "the system",
              "drivingLicenseNumber": "present in",
              "dateOfBirth": "data",
              "driverId": "",
            }
          ];

    // if(newdata.length==0)
    // return [DataRow(cells: [
    //   DataCell(Text("No Data about drivers Present"))
    // ])];
    // print(newdata);

    return newdata.map((driver) {
      return DataRow(cells: [
        DataCell(Text(
            driver['firstName'].toString() +
                " " +
                driver['lastName'].toString(),
            style: txtbhstyle)),
        DataCell(Text(
          driver['driverEmail'].toString(),
          style: txtbhstyle,
        )),
        DataCell(Text(driver['dateOfBirth'].toString(), style: txtbhstyle)),
        DataCell(
            Text(driver['driverLicenseNumber'].toString(), style: txtbhstyle)),
        DataCell(Text(driver['driverMobile'].toString(), style: txtbhstyle)),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.edit),
          onPressed: widget.editDriver(driver['driverId']),
        )),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.delete),
          onPressed: () {
            // if(driver['driverId']==null) return;
            dio
                .delete('/admin/api/deleteDriver?id=${driver["driverId"]}')
                .then((value) {
              if (value.data['status'] == 1) {
                dio.get("/admin/api/getDrivers").then((value) {
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
                      SubTitleText("Add Driver")
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
                              child: MediumText("Add Driver")))
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
                          DataColumn(label: Text("Name", style: txtbhstyle)),
                          DataColumn(label: Text("Email", style: txtbhstyle)),
                          DataColumn(
                              label: Text("Birth Date", style: txtbhstyle)),
                          DataColumn(
                              label: Text("Driving License\n Number",
                                  style: txtbhstyle)),
                          DataColumn(
                              label: Text("Mobile Number", style: txtbhstyle)),
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

class DriverLayout extends StatefulWidget {
  const DriverLayout({Key? key}) : super(key: key);

  @override
  State<DriverLayout> createState() => _DriverLayoutState();
}

class _DriverLayoutState extends State<DriverLayout> {
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
        return DriverForm(
          width: AdminWidget.getWidth(context),
          showDriverList: () {
            setState(() {
              this.mode = 0;
            });
          },
        );
      } else if (this.mode == 2) {
        return DriverForm(
            width: AdminWidget.getWidth(context),
            id: this.id,
            showDriverList: () {
              setState(() {
                this.mode = 0;
              });
            });
      } else {
        return DriverDataTable(
            width: AdminWidget.getWidth(context),
            addDriver: () {
              setState(() {
                this.mode = 1;
              });
            },
            editDriver: (String id) => () {
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
