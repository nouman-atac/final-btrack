// ignore_for_file: unused_import, must_be_immutable, must_call_super, body_might_complete_normally_nullable

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

class BusRouteForm extends StatefulWidget {
  // mode    1= Add    2= Edit
  static const String route = '/driverAddForm';
  BusRouteForm(
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
  State<BusRouteForm> createState() => _BusRouteForm();
}

class _BusRouteForm extends State<BusRouteForm> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  // Key
  PageController pageController = PageController();
  var currentTime = DateTime(2022);

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  List busStops = [
    {
      "busStopId": "",
      "busStopName": "Select",
      "coordinates": [-1.0, -1.0]
    }
  ];

  List<String> stops = ["Start Stop / Stop 0", "End Stop"];

  String? map_box_url, wayPoints = "";
  late String access_token;
  LatLng? center = LatLng(18.9766, 72.8323);
  LatLng busStopMarker = LatLng(19.0178, 72.8478);
  late List<Marker> markers;
  List<List<LatLng>> routes = [];
  int index = 0;
  int markerSet = 0;
  List<LatLng> points = [];
  Dio mapboxDio = Dio();

  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));

  Map<String, dynamic> data = {
    "mode": 0,
    "busRouteNumber": -1,
    "busStopIds": ["", ""],
    "numberOfStops": "2",
  };

  void initState() {
    access_token =
        "pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA2d2E0eWYwMHpzM2NwZnA1NTFyamxkIn0.p87DFwS20cCG1Sa61WPo9g";
    map_box_url =
        "https://api.mapbox.com/styles/v1/noumankhwaja2/cl054ae5l001m15o3jnps81ye/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg";
    List<Marker> newMarkers = [];
    dio.get("/admin/api/getBusStops").then((result) {
      if (result.data['status'] == 1) {
        // print(result.data);
        newMarkers = result.data['data'].map<Marker>((e) {
          return Marker(
              point: LatLng(double.parse(e['coordinates']['latitude']),
                  double.parse(e['coordinates']['longitude'])),
              builder: (BuildContext context) {
                return Tooltip(
                  message:
                      "${e['busStopName']}\n ${e['landmark']}\n${e['city']}-${e['pincode']}",
                  textStyle: TextStyle(
                    color: MyColors.bWhite,
                    fontSize: 17,
                  ),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: MyColors.navyBlue,
                  ),
                  child: Icon(
                    Icons.place,
                    color: MyColors.failure,
                    size: 30,
                  ),
                );
              });
        }).toList();
        setState(() {
          busStops.addAll(result.data['data']);
          this.markers = newMarkers;
          this.markerSet = 1;

          print(busStops);
        });
      } else {
        setState(() {
          this.messageText = "Bus Stop Data is not properly loaded";
          this.messageContainerColor = MyColors.failure;
          this.messageContainerHeight = 40.0;
          this.messageCancelIconSize = 15.0;
        });
      }
    }).onError((error, stackTrace) {
      print(error);
    });
    if (widget.id != null || DataId.driverId != null) {
      dio
          .get(
              "/admin/api/getBusRoute?number=${widget.id == null ? DataId.driverId : widget.id}")
          .then((result) {
        if (result.data["status"] == 0) {
          setState(() {
            this.messageText = "Driver data is not available";
            this.messageContainerColor = MyColors.failure;
            this.messageContainerHeight = 40.0;
            this.messageCancelIconSize = 15.0;
          });
        } else {
          List<LatLng> newRoute = [];
          int i = 0;
          print(result.data['data']['routeGeometry']);
          print(result.data);

          for (; i < result.data['data']['routeGeometry'].length; i++)
            newRoute.add(LatLng(
                double.parse(
                    result.data['data']['routeGeometry'][i]['latitude']),
                double.parse(
                    result.data['data']['routeGeometry'][i]['longitude'])));

          this.routes.add(newRoute);

          setState(() {
            this.points = newRoute;
            this.data = result.data['data'];
            this.data['mode'] = 1;
            this.data['oldBusStopIds'] = <String>[
              ...result.data['data']['busStopIds']
            ];
            this.data['busStopIds'] = <String>[
              ...result.data['data']['busStopIds']
            ];
          });
        }
      }, onError: (err) {
        print(err);
      });
    }
  }

  List<Widget> selectorsRows(List<Widget> selectors) {
    List<Widget> rows = [];

    for (int i = 0; i < selectors.length; i++) {
      rows.add(FormRow(children: [
        selectors[i++],
        i < selectors.length
            ? selectors[i]
            : SizedBox(
                width: 0,
                height: 0,
              ),
      ]));
    }
    return rows;
  }

  List<Widget> busStopSelectors([int number = 2]) {
    List<Widget> selectors = [];
    String fieldname = "";

    for (int i = 0; i < number; i++) {
      if (i == 0) selectors = [];
      fieldname = i == 0 ? "Start Stop/ " : (i == number - 1 ? "End Stop" : "");
      fieldname += "Stop ${i}";

      selectors.add(
        MyDropDownFormField(
            fieldName: fieldname,
            initialValue: this.data['busStopIds'][i].toString(),
            items: this
                .busStops
                .map<DropdownMenuItem<dynamic>>((dynamic newValue) {
              return DropdownMenuItem(
                value: newValue['busStopId'],
                child: Text(newValue['busStopName'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              this.data['busStopIds'][i] = value.toString();
              print(this.data['busStopIds']);
            },
            validator: (String? value) {
              if (value == null || value == "")
                return "Please Select SomeThing";
              else
                return null;
            }),
      );
    }
    return selectors;
  }

  List<Map<String, dynamic>> getSelectedStops(List<String> ids) {
    List<Map<String, dynamic>> selectedStops = [];
    for (var id in ids) {
      selectedStops.add(this.busStops.firstWhere((element) {
        return element['busStopId'] == id;
      }));
    }
    return selectedStops;
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
                                    ? "Add Bus Route"
                                    : "Update Bus Route")
                              ],
                            ),
                            Divider(
                              height: 50,
                            ),
                            FormRow(children: [
                              MyTextFormField(
                                fieldName: "Bus Route Number",
                                initialValue:
                                    this.data['busRouteNumber'].toString(),
                                onChanged: (value) {
                                  this.data['busRouteNumber'] = value;
                                },
                                validator: (value) {
                                  if (value != null &&
                                      !Validator.isInteger(value)) {
                                    return "Value must be numeric example: 1";
                                  }

                                  if (int.parse(value != null ? value : "-1") <
                                      1) {
                                    return "Value should be greater than 0";
                                  }
                                  return null;
                                },
                              ),
                              MyDropDownFormField(
                                fieldName: "Number of Stops",
                                initialValue:
                                    this.data['numberOfStops'].toString(),
                                items: [
                                  for (int i = 2; i < 101; i++) i.toString(),
                                ].map<DropdownMenuItem<String>>(
                                    (String newValue) {
                                  return DropdownMenuItem(
                                    value: newValue.toString(),
                                    child: Text(newValue.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  this.data['busStopIds'] = [
                                    for (int i = 0; i < int.parse(value); i++)
                                      ""
                                  ];
                                  print("5: ${this.data['busStopIds']}");
                                  setState(() {
                                    this.data['numberOfStops'] = value;
                                  });
                                },
                                validator: (String? value) {
                                  if (value == null || value == "")
                                    return "Please Select SomeThing";

                                  return null;
                                },
                              ),
                            ]),
                            for (var i in selectorsRows(busStopSelectors(
                                int.parse(this.data["numberOfStops"]))))
                              i,
                            SizedBox(
                              height: 30,
                            ),
                            FormRow(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: MyColors.cobaltBlue,
                                      width: 3,
                                    ),
                                  ),
                                  width: 600,
                                  height: 500,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      center: this.center,
                                      zoom: 14.0,
                                      onLongPress: (point, coordinate) {
                                        setState(() {
                                          this.center = coordinate;
                                          this.busStopMarker = coordinate;
                                        });
                                      },
                                    ),
                                    layers: [
                                      TileLayerOptions(
                                          urlTemplate: this.map_box_url,
                                          additionalOptions: {
                                            'accessToken': this.access_token
                                          }),
                                      if (this.points.length > 0)
                                        PolylineLayerOptions(polylines: [
                                          Polyline(
                                              points: this.points,
                                              strokeWidth: 6.0,
                                              color: MyColors.cobaltBlue)
                                        ]),
                                      if (markerSet != 0)
                                        MarkerLayerOptions(
                                          markers: this.markers,
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Container(
                                  width: 300,
                                  height: 500,
                                  child: Column(children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          for (var id
                                              in this.data['busStopIds']) {
                                            if (id.isEmpty) {
                                              setState(() {
                                                this.messageText =
                                                    "Please Reselect all the Stops";
                                                this.messageContainerColor =
                                                    MyColors.failure;
                                                this.messageContainerHeight =
                                                    40.0;
                                                this.messageCancelIconSize =
                                                    15.0;
                                              });
                                              return null;
                                            }
                                          }
                                          late List<Map<String, dynamic>>
                                              selectedStops;
                                          print(
                                              "1: ${this.data['busStopIds']}");
                                          try {
                                            selectedStops = getSelectedStops(
                                                this.data["busStopIds"]);
                                          } catch (e) {
                                            print(e);
                                            return null;
                                          }
                                          print(
                                              "2: ${this.data['busStopIds']}");

                                          this.wayPoints = "";
                                          print(selectedStops);
                                          for (var stop in selectedStops) {
                                            this.wayPoints = this.wayPoints! +
                                                "${stop["coordinates"]['longitude']}%2C${stop['coordinates']['latitude']}%3B";
                                          }
                                          print(
                                              "3: ${this.data['busStopIds']}");

                                          print(this.wayPoints);
                                          // print(newMarkers);
                                          mapboxDio
                                              .get(
                                                  "https://api.mapbox.com/directions/v5/mapbox/driving/${this.wayPoints!.substring(0, this.wayPoints!.length - 3)}?alternatives=true&geometries=geojson&language=en&overview=simplified&steps=true&access_token=${this.access_token}")
                                              .then((response) {
                                            List<List<LatLng>> newRoutes = [];
                                            late int i;
                                            for (i = 0;
                                                i <
                                                    response
                                                        .data['routes'].length;
                                                i++) {
                                              newRoutes.add(response
                                                  .data['routes'][i]['geometry']
                                                      ['coordinates']
                                                  .map<LatLng>((value) {
                                                return LatLng(
                                                    value[1], value[0]);
                                              }).toList());
                                            }

                                            this.routes = newRoutes;
                                            setState(() {
                                              this.points =
                                                  newRoutes[this.index];
                                              this.center = LatLng(
                                                  double.parse(selectedStops[0]
                                                          ['coordinates']
                                                      ['latitude']),
                                                  double.parse(selectedStops[0]
                                                          ['coordinates']
                                                      ['longitude']));
                                            });
                                            print(
                                                "4: ${this.data['busStopIds']}");
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  MyColors.cobaltBlue),
                                          elevation:
                                              MaterialStateProperty.all(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text("Generate Routes",
                                              style: btntxtstyle),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    DropdownButtonFormField(
                                      value: 1,
                                      items: [
                                        for (int i = 1;
                                            i <= this.routes.length;
                                            i++)
                                          i
                                      ].map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(value.toString()));
                                      }).toList(),
                                      decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MyColors.cobaltBlue,
                                                width: 3),
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: MyColors.cobaltBlue,
                                                  width: 3)),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.only(
                                              left: 20, top: 10)),
                                      onChanged: (value) {
                                        setState(() {
                                          this.index =
                                              int.parse(value.toString()) - 1;
                                          this.points = this.routes[index];
                                        });
                                      },
                                    )
                                  ]),
                                )
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
                                      this.data['routeGeometry'] = this
                                          .routes[index]
                                          .map<Map<String, double>>(
                                              (LatLng coordinate) {
                                        return {
                                          "latitude": coordinate.latitude,
                                          "longitude": coordinate.longitude
                                        };
                                      }).toList();
                                      // print(this.data);

                                      try {
                                        await dio
                                            .post(
                                                this.data['mode'] == 0
                                                    ? "/admin/api/addBusRoute"
                                                    : "/admin/api/updateBusRoute",
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
                                          this.data['oldBusStopIds'] =
                                              this.data['busStopIds'];
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

class BusRouteTable extends StatefulWidget {
  BusRouteTable(
      {Key? key, required this.width, this.addDriver, this.editDriver})
      : super(key: key);
  double width;
  void Function()? addDriver;
  var editDriver;

  @override
  _BusRouteTableState createState() => _BusRouteTableState();
}

class _BusRouteTableState extends State<BusRouteTable> {
  PageController page = PageController();
  Dio dio = new Dio(BaseOptions(baseUrl: "http://localhost:5000"));
  var rows = null;

  String messageText = "";
  double messageContainerHeight = 0.0, messageCancelIconSize = 0.0;
  Color? messageContainerColor = null;

  @override
  void initState() {
    super.initState();
    dio.get("/admin/api/getBusRoutes").then((value) {
      print(value.data['data'].runtimeType);
      print(value.data['data']);
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
              "busRouteNumber": '',
              "busStopIds": [""],
              "numberOfStops": '1',
              "stops": [
                {"busStopName": ""}
              ],
              "createdBy": ''
            }
          ];

    if (newdata.length == 0) return [];
    // print(newdata[0]['stops'].runtimeType);

    return newdata.map((route) {
      List<dynamic> stops = route['stops'].toList();
      List<int> indexes = getIndexOfStop(stops, [
        route["busStopIds"][0],
        route["busStopIds"][(int.parse(route["numberOfStops"]) - 1)]
      ]);
      return DataRow(cells: [
        DataCell(Text(
          route['busRouteNumber'].toString(),
          style: txtbhstyle,
        )),
        DataCell(Text(route['numberOfStops'].toString(), style: txtbhstyle)),
        DataCell(Text(stops[indexes[0]]['busStopName'].toString(),
            style: txtbhstyle)),
        DataCell(Text(stops[indexes[1]]['busStopName'].toString(),
            style: txtbhstyle)),
        DataCell(Text(route['createdBy'].toString(), style: txtbhstyle)),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.edit),
          onPressed: widget.editDriver(route['busRouteNumber']),
        )),
        DataCell(IconButton(
          color: MyColors.cobaltBlue,
          icon: Icon(Icons.delete),
          onPressed: () {
            // if(driver['driverId']==null) return;
            dio
                .delete(
                    '/admin/api/deleteBusRoute?number=${route["busRouteNumber"]}')
                .then((value) {
              if (value.data['status'] == 1) {
                dio.get("/admin/api/getBusRoutes").then((value) {
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

  List<int> getIndexOfStop(List<dynamic> l, List<String> values) {
    List<int> indexes = [0, 0];
    late int i;
    for (i = 0; i < l.length; i++) {
      if (l[i].containsValue(values[0])) indexes[0] = i;
      if (l[i].containsValue(values[1])) indexes[1] = i;
    }
    return indexes;
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
                      SubTitleText("Bus Routes")
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
                              child: MediumText("Add Bus Route")))
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
                            "Route Number",
                            style: txtbhstyle,
                          )),
                          DataColumn(
                              label: Text("Number Stops", style: txtbhstyle)),
                          DataColumn(
                              label: Text("First Stop", style: txtbhstyle)),
                          DataColumn(
                              label: Text("Last Stop", style: txtbhstyle)),
                          DataColumn(
                              label: Text("Creted By", style: txtbhstyle)),
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

class BusRouteLayout extends StatefulWidget {
  const BusRouteLayout({Key? key}) : super(key: key);

  @override
  State<BusRouteLayout> createState() => _BusRouteLayoutState();
}

class _BusRouteLayoutState extends State<BusRouteLayout> {
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
        return BusRouteForm(
          width: AdminWidget.getWidth(context),
          showDriverList: () {
            setState(() {
              this.mode = 0;
            });
          },
        );
      } else if (this.mode == 2) {
        return BusRouteForm(
            width: AdminWidget.getWidth(context),
            id: this.id,
            showDriverList: () {
              setState(() {
                this.mode = 0;
              });
            });
      } else {
        return BusRouteTable(
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
