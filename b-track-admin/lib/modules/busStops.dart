// ignore_for_file: unused_import, must_be_immutable, unused_local_variable, must_call_super, body_might_complete_normally_nullable, unused_field

import 'dart:async';
import 'dart:io';
import 'dart:js';

import 'package:client/button.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
// import 'package:mapbox_gl/mapbox_gl.dart' hide LatLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_api/mapbox_api.dart';

import 'package:client/formElement.dart';
import 'package:client/try.dart';
import 'package:client/validate.dart';
import '../textComponent.dart';
import '../resources.dart';
import '../validate.dart';
import '../viewComponent.dart';
import 'adminWidget.dart';
import 'drivers.dart';
import 'buses.dart';
import 'maps.dart';

class DataId {
  static String? driverId;
}

class BusStopForm extends StatefulWidget {
  // mode    1= Add    2= Edit
  static const String route = '/driverAddForm';
  BusStopForm(
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
  State<BusStopForm> createState() => _BusStopForm();
}

class _BusStopForm extends State<BusStopForm> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  // Key
  PageController pageController = PageController();
  var currentTime = DateTime(2022);

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));

  late String access_token;
  String? map_box_url;
  LatLng? center = LatLng(19.0178, 72.8478);
  LatLng busStopMarker = LatLng(19.0178, 72.8478);
  String searchString = "";
  String reverseGeoString = "Dadar";

  late MapController _controller;

  MapboxApi mapboxApi = MapboxApi(
      accessToken:
          "sk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MzBodnMwc3psM2VxZG83OHZ6aTY3In0.VXgrtMszdfP6etwtsGzg0g");
  void _forwardGeocoding(String searchText) {
    var response = mapboxApi.forwardGeocoding.request(
        language: 'en',
        fuzzyMatch: true,
        // country: ['India'],
        searchText: searchText,
        proximity: [19.0178, 72.8478]).then((value) {
      print(value.features![0].center);

      setState(() {
        _controller.move(
            LatLng(
                value.features![0].center![1], value.features![0].center![0]),
            16.0);
        this.busStopMarker = LatLng(
            value.features![0].center![1], value.features![0].center![0]);
      });
      _reverseGeocoding(
          LatLng(value.features![0].center![1], value.features![0].center![0]));
    });
  }

  void _reverseGeocoding(LatLng latLng) {
    mapboxApi.reverseGeocoding.request(
      coordinate: [latLng.longitude, latLng.latitude],
      language: "en",
    ).then((value) {
      print(value);
    }).onError((error, stackTrace) {
      print("Not able to get reverse geo coding");
    });
  }

  Map<String, dynamic> data = {
    "mode": 0,
    "busStopName": "",
    "address": "",
    "landmark": "",
    "country": "India",
    "state": "Maharashtra",
    "city": "Mumbai",
    "pincode": "",
    "coordinates": {"latitude": 19.0178, "longitude": 72.8478}
  };

  void initState() {
    access_token =
        "pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA2d2E0eWYwMHpzM2NwZnA1NTFyamxkIn0.p87DFwS20cCG1Sa61WPo9g";
    map_box_url =
        "https://api.mapbox.com/styles/v1/noumankhwaja2/cl054ae5l001m15o3jnps81ye/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg";

    if (widget.id != null || DataId.driverId != null) {
      dio
          .get(
              "/admin/api/getBusStop?id=${widget.id == null ? DataId.driverId : widget.id}")
          .then((result) {
        print(result.data['data']['busStopName']);
        if (result.data["status"] == 0) {
          setState(() {
            this.messageText = "Bus Stop data is not available";
            this.messageContainerColor = MyColors.failure;
            this.messageContainerHeight = 40.0;
            this.messageCancelIconSize = 15.0;
          });
        } else {
          double longitude =
              double.parse(result.data['data']['coordinates']['longitude']);
          double latitude =
              double.parse(result.data['data']['coordinates']['latitude']);
          print(result.data['data']['coordinates']['latitude']);
          setState(() {
            this.data = result.data['data'];
            this.data['mode'] = 1;
            this.center = LatLng(latitude, longitude);
            this.busStopMarker = LatLng(latitude, longitude);
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
                                        child: MediumText("Bus Stop List")))
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
                                    ? "Add Bus Stop"
                                    : "Update Bus Stop")
                              ],
                            ),
                            Divider(
                              height: 50,
                            ),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "Bus Stop Name",
                                initialValue:
                                    this.data['busStopName'].toString(),
                                onChanged: (value) {
                                  this.data['busStopName'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter a Bus Stop Name';
                                  }
                                  return null;
                                },
                              ),
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
                            ]),

                            FormRow(children: [
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
                            ]),
                            FormRow(children: [
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
                            ]),
                            FormRow(children: [
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

                            // FormRow(
                            //   children: [
                            //   MyTextFormField(fieldName: "Pincode", initialValue:this.data['pincode'],onChanged: (value){this.data['pincode']=value;},validator:(value)=>null),
                            //   ],
                            // ),
                            FormRow(children: [
                              // Add Map
                              // Maps()
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Bus Stop Location:",
                                    style: txtbhstyle,
                                  ),
                                  SizedBox(
                                    height: 13.0,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: MyColors.cobaltBlue,
                                        width: 3,
                                      ),
                                    ),
                                    width: 500,
                                    height: 500,
                                    child: FlutterMap(
                                      options: MapOptions(
                                          onMapCreated: (mapController) {
                                            _controller = mapController;
                                          },
                                          center: this.center,
                                          zoom: 16.0,
                                          onLongPress: (point, coordinate) {
                                            setState(() {
                                              this.center = coordinate;
                                              this.busStopMarker = coordinate;
                                            });
                                          }),
                                      layers: [
                                        TileLayerOptions(
                                            urlTemplate: this.map_box_url,
                                            additionalOptions: {
                                              'accessToken': this.access_token
                                            }),
                                        MarkerLayerOptions(markers: [
                                          Marker(
                                              point: this.busStopMarker,
                                              builder: (context) {
                                                return Icon(
                                                  Icons.place,
                                                  color: MyColors.failure,
                                                  size: 35.0,
                                                );
                                              })
                                        ])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                    child: MyTextFormField(
                                      fieldName: "Search",
                                      validator: (value) => null,
                                      onChanged: (value) {
                                        this.searchString = value;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(180, 0, 0, 0),
                                      child: HoverButton(
                                        onPressed: () {
                                          this._forwardGeocoding(
                                              this.searchString);
                                        },
                                        width: 130,
                                        height: 50,
                                        color: MyColors.cobaltBlue,
                                        hoverColor:
                                            Color.fromARGB(255, 66, 72, 115),
                                        child: Text(
                                          "Search ",
                                          style: btntxtstyle,
                                        ),
                                      )),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          "Lattitude: ${this.busStopMarker.latitude}",
                                          style: txtbhstyle,
                                        ),
                                        SelectableText(
                                          "Longitude: ${this.busStopMarker.longitude}",
                                          style: txtbhstyle,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ]),
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
                                      this.data['coordinates']['latitude'] =
                                          this.busStopMarker.latitude;
                                      this.data['coordinates']['longitude'] =
                                          this.busStopMarker.longitude;
                                      // print(this.data);
                                      try {
                                        // this.data.remove("driverImage");
                                        // this.data['driverImage']=this.data["driverImage"]
                                        // var temp = this.data["driverImage"]["imageBytes"];
                                        // this.data["driverImage"]["imageBytes"]= ;

                                        await dio
                                            .post(
                                                this.data['mode'] == 0
                                                    ? "/admin/api/addBusStop"
                                                    : "/admin/api/updateBusStop",
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

class BusStopDataTable extends StatefulWidget {
  BusStopDataTable(
      {Key? key, required this.width, this.addBusStop, this.editBusStop})
      : super(key: key);
  double width;
  void Function()? addBusStop;
  var editBusStop;

  @override
  _BusStopDataTableState createState() => _BusStopDataTableState();
}

class _BusStopDataTableState extends State<BusStopDataTable> {
  PageController page = PageController();
  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));
  var rows = null;

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  @override
  void initState() {
    super.initState();
    dio.get("/admin/api/getBusStops").then((value) {
      print(value.data['data'].runtimeType);
      print(value.data['data']);
      setState(() {
        this.rows = value.data['data'];
      });
    }).onError((error, stackTrace) => null);
  }

  List<DataRow> _getRows(BuildContext context, List<dynamic>? data) {
    var newdata = data != null
        ? data
        : [
            {
              "busStopId": "",
              "busStopName": "",
              "address": "",
              "landmark": "",
              "country": "India",
              "state": "Maharashtra",
              "city": "Mumbai",
              "pincode": "",
              "coordinates": {"latitude": 54.32, "longitude": 32.65}
            }
          ];

    // if(newdata.length==0)
    // return [DataRow(cells: [
    //   DataCell(Text("No Data about drivers Present"))
    // ])];
    // print(newdata);

    return newdata.map((busStop) {
      return DataRow(cells: [
        DataCell(Text(
          busStop['busStopName'].toString(),
          style: txtbhstyle,
        )),
        DataCell(Text(busStop['landmark'].toString(), style: txtbhstyle)),
        DataCell(Text(busStop['pincode'].toString(), style: txtbhstyle)),
        DataCell(Text(busStop['city'].toString(), style: txtbhstyle)),
        DataCell(Text(busStop['coordinates']['latitude'].toString(),
            style: txtbhstyle)),
        DataCell(Text(busStop['coordinates']['longitude'].toString(),
            style: txtbhstyle)),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.edit),
          onPressed: widget.editBusStop(busStop['busStopId']),
        )),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.delete),
          onPressed: () {
            // if(driver['driverId']==null) return;
            dio
                .delete('/admin/api/deleteBusStop?id=${busStop["busStopId"]}')
                .then((value) {
              if (value.data['status'] == 1) {
                dio.get("/admin/api/getBusStops").then((value) {
                  print(value.data['data'].runtimeType);
                  setState(() {
                    this.messageText = "Delete Successful";
                    this.messageContainerHeight = 40.0;
                    this.messageContainerColor = MyColors.success;
                    this.messageCancelIconSize = 15.0;
                    this.rows = value.data['data'];
                  });
                });
              } else if (value.data['status'] == 0) {
                setState(() {
                  this.messageText = value.data['msg'];
                  this.messageContainerHeight = 40.0;
                  this.messageContainerColor = MyColors.failure;
                  this.messageCancelIconSize = 15.0;
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
                      SubTitleText("Bus Stop List")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: widget.addBusStop,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(MyColors.cobaltBlue),
                            elevation: MaterialStateProperty.all(20.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: MediumText("Add Bus Stop")))
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
                            "Stop Name",
                            style: txtbhstyle,
                          )),
                          DataColumn(
                              label: Text("Landmark", style: txtbhstyle)),
                          DataColumn(label: Text("Pincode", style: txtbhstyle)),
                          DataColumn(label: Text("City", style: txtbhstyle)),
                          DataColumn(
                              label: Text("Location\nLattitude",
                                  style: txtbhstyle)),
                          DataColumn(
                              label: Text("Location\nLongitude",
                                  style: txtbhstyle)),
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

class BusStopLayout extends StatefulWidget {
  const BusStopLayout({Key? key}) : super(key: key);

  @override
  State<BusStopLayout> createState() => _BusStopLayoutState();
}

class _BusStopLayoutState extends State<BusStopLayout> {
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
        return BusStopForm(
          width: AdminWidget.getWidth(context),
          showDriverList: () {
            setState(() {
              this.mode = 0;
            });
          },
        );
      } else if (this.mode == 2) {
        return BusStopForm(
            width: AdminWidget.getWidth(context),
            id: this.id,
            showDriverList: () {
              setState(() {
                this.mode = 0;
              });
            });
      } else {
        return BusStopDataTable(
            width: AdminWidget.getWidth(context),
            addBusStop: () {
              setState(() {
                this.mode = 1;
              });
            },
            editBusStop: (String id) => () {
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
