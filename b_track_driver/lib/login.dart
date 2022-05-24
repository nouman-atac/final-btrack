// ignore_for_file: use_key_in_widget_constructors, camel_case_types, prefer_const_constructors, unnecessary_new, unrelated_type_equality_checks, unnecessary_type_check
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'package:b_track_driver/AdminWidget.dart';
import 'package:b_track_driver/SuccessfulLogin.dart';
import 'package:b_track_driver/textfieldstyle.dart';
import 'package:b_track_driver/BusJourney.dart';
import 'NavBar.dart';





final style = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.white,
  fontSize: 15,
));

final estyle = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Colors.red[900],
  fontSize: 12,
));

final buttonstyle = ElevatedButton.styleFrom(
    fixedSize: Size(150, 40),
    primary: Color(0xfffb713c),
    elevation: 15,
    shadowColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      //side: BorderSide(color: Colors.grey.shade800),
    ));

class login extends StatefulWidget {
  String? msg;
  login({Key? key,this.msg}):super(key: key);
  @override
  _login createState() => _login();
}

class _login extends State<login> {
  bool _isVisible = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.msg!=null)
     {
       WidgetsBinding.instance?.addPostFrameCallback((_) {
    // do something
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.msg!)));
     
  });
     } 

  }

  @override
  Widget build(BuildContext context) {
    // print(AdminWidget.appDocDir.path);
    // print(AdminWidget.cookieJar.hostCookies);
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_rounded),
        //   color: Colors.white,
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        title: Text('Login',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
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
                    controller: email,
                    cursorColor: Colors.grey.shade500,
                    decoration: buildInputDecoration(),
                    style: TextStyle(color: Colors.grey.shade800),
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
                    cursorColor: Colors.grey.shade500,
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
                                  color: Color(0xfffb713c),
                                )
                              : Icon(Icons.visibility_off,
                                  color: Color(0xfffb713c)),
                        ),
                        contentPadding: EdgeInsets.only(left: 25),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Color(0xfffb713c))),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Color(0xfffb713c))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(color: Color(0xfffb713c))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid password';
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
                        AdminWidget.dio.post("/driver/login",data:{ 
                          "driverEmail": email.text, "password": password.text 
                          }).then((value){
                          var data =value.data;
                          print(data);
                          if(data['authenticated']==true){
                            // print("Cookies");
                            AdminWidget.cookieJar.loadForRequest(Uri.parse("http://41c3-183-87-104-184.ngrok.io")).then((cookie) {
                              print("Cookies: ${cookie}");

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
                        // AdminWidget.dio.get("/driver/api/getRunningBusRoute").then((value) {
                        //   print(value);
                        // },).onError((error, stackTrace) {
                        //   print(error.toString());
                        // });
                        
                        
                        print(email.text);
                        print(password.text);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => successpage2()));
                      }
                    },
                    style: buttonstyle),
              )),
            ],
          )),
    );
  }
}

class GetBus extends StatefulWidget {
  @override
  _GetBus createState() => _GetBus();
}

class _GetBus extends State<GetBus> {
  bool _isVisible = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController busRegistration=TextEditingController();
  // TextEditingController password=TextEditingController();

    Future<void> _showMyDialog({required String msg,required String label, required Widget nextPage}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children:  <Widget>[
              Text(msg)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(label),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => nextPage));
            },
          ),
        ],
      );
    },
  );
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    AdminWidget.dio.post("/driver/api/deSelectBus").then((value){
      var data = value.data;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
    }).onError((error, stackTrace){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(AdminWidget.appDocDir.path);
    // print(AdminWidget.cookieJar.hostCookies);
   
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.grid_view_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NavBar()));
          },
        ),
        title: Text('Bus Selection',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
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
                  'Bus Registration Number',
                  style: style,
                ),
              )),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                    controller: busRegistration,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 10,
                    cursorColor: Colors.grey.shade500,
                    decoration: buildInputDecoration(),
                    style: TextStyle(color: Colors.grey.shade800),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Bus Registration Number';
                      }
                      if (value.length != 10) {
                        return 'Please Enter valid Bus Registration Number';
                      } else if (value is String &&
                          !RegExp("[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}")
                              .hasMatch(value)) {
                        return 'Please Enter Valid Bus Registration Number';
                      }
                      return null;
                    }),
              )),
             
            
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ElevatedButton(
                    child: Text("Select Bus", style: style),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AdminWidget.dio.post("/driver/api/selectBus",data:{ 
                          "busRegistrationNumber": busRegistration.text
                          }).then((value){
                          var data =value.data;
                          print(data);
                        
                          if(data['status']==-1){
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          _showMyDialog(msg: data['msg'], label: "Login Page", nextPage: login());
                          }else if(data['status']==1){
                            // Navigator.push(context, MaterialPageRoute(builder: (builder)=> SelectRoute()));
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectRoute(msg:data['msg'])));
                            
                          }
                          else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          }
                        }).onError((error, stackTrace) {
                          var snackBar= SnackBar(content: Text(error.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            print(error.toString());
                        });
                        // AdminWidget.dio.get("/driver/api/getRunningBusRoute").then((value) {
                        //   print(value);
                        // },).onError((error, stackTrace) {
                        //   print(error.toString());
                        // });
                        
                        
                        print(busRegistration.text);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => successpage2()));
                      }
                    },
                    style: buttonstyle),
              )),
            ],
          )),
    );
  }
}

class SelectRoute extends StatefulWidget {
  String? msg;
  SelectRoute({Key? key,this.msg}):super(key: key);
  @override
  _SelectRoute createState() => _SelectRoute();
}

class _SelectRoute extends State<SelectRoute> {
  bool _isVisible = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController routeNumber=TextEditingController();
  late MapController _mapController;
  LatLng center= LatLng(18.967928, 72.831404);
  LatLng marker= LatLng(18.967928, 72.831404);
  Location location=Location();
  // TextEditingController password=TextEditingController();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  var previousLatitude = 18.967928,previousLongitude=72.831404;

    Future<void> _showMyDialog({required String msg,required String label, required Widget nextPage}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children:  <Widget>[
              Text(msg)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(label),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => nextPage));
            },
          ),
        ],
      );
    },
  );
}

Future<void> locationSetup() async{
    _serviceEnabled = await location.serviceEnabled();
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  if (!_serviceEnabled) {
    return;
  }
}

_permissionGranted = await location.hasPermission();
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  if (_permissionGranted != PermissionStatus.granted) {
    return;
  }
}

_locationData = await location.getLocation();
}

void initState(){
  AdminWidget.dio.get("/driver/api/").then(((value) {
      var data = value.data;
      if(data['status']==-1){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>login(msg: "Session Expired Please log in first ",)));
      }
    }));
    if(widget.msg!=null)
      WidgetsBinding.instance?.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.msg!)));   
  });

  locationSetup().then(((value) {
    print(this._locationData);
  print(_permissionGranted);
  print(_serviceEnabled);
  double temp=previousLatitude;
  if(_locationData.latitude!=null&&_locationData.longitude!=null){
    previousLatitude=_locationData.latitude!;
    previousLongitude= _locationData.longitude!;
  }
 
  setState(() {
    marker = LatLng(previousLatitude,previousLongitude);
  });
  _mapController.move(marker, 15);
  }));
  
  
}

  @override
  Widget build(BuildContext context) {
    // print(AdminWidget.appDocDir.path);
    // print(AdminWidget.cookieJar.hostCookies);
   
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.grid_view_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NavBar()));
          },
        ),
        title: Text('Route Selection',
            style: GoogleFonts.rowdies(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
        elevation: 0,
      ),
      body:Container(
        child: Column(
          children: [
            Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Bus Route Number',
                  style: style,
                ),
              )),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                    controller: routeNumber,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 10,
                    cursorColor: Colors.grey.shade500,
                    decoration: buildInputDecoration(),
                    style: TextStyle(color: Colors.grey.shade800),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a number';
                      }
                       try{
                         int.parse(value);
                       }catch(e){
                         return "Please enter a number and not character";
                       }
                      return null;
                    }),
              )),
             
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: ElevatedButton(
                    child: Text("Select Route", style: style),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AdminWidget.dio.post("/driver/api/selectRoute",data:{ 
                          "busRouteNumber": routeNumber.text
                          }).then((value){
                          var data =value.data;
                          print(data);
                        
                          if(data['status']==-1){
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          _showMyDialog(msg: data['msg'], label: "Login Page", nextPage: login());
                          }else if(data['status']==1){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=> BusJourney()));
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
                        // AdminWidget.dio.get("/driver/api/getRunningBusRoute").then((value) {
                        //   print(value);
                        // },).onError((error, stackTrace) {
                        //   print(error.toString());
                        // });
                        
                        
                        print(routeNumber.text);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => successpage2()));
                      }
                    },
                    style: buttonstyle),
              )),
            
            ],
          )),
          Center(
               child: Container(
                //  color: Colors.white,
                 width: 320,
                 height: 400,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(5),
                   border: Border.all(width: 4,color: Colors.white),
                 ),
                 child:FlutterMap(
                   options: MapOptions(
                     zoom: 15.0,
                     center: center,
                     maxZoom: 17.5,
                    //  minZoom: 10.0,
                     onMapCreated: (mapContoller){
                       _mapController=mapContoller;
                     },
                    //  onLongPress: (pos,loc){
                    //    print(loc);
                    //    setState(() {
                    //      marker=loc;
                    //    });
                    //  }
                   ),
                   layers: [
                     TileLayerOptions(
                       urlTemplate: "https://api.mapbox.com/styles/v1/noumankhwaja2/cl054ae5l001m15o3jnps81ye/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg",
                       additionalOptions: {
                         "accessToken":"pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg"
                       }
                     ),
                     MarkerLayerOptions(
                       markers: [
                         Marker(
                          point: marker,
                          builder: (context){
                            return Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 50, 131, 224),
                                    blurRadius: 3,
                                    blurStyle: BlurStyle.outer
                                  )
                                ],
                                border: Border.all(
                                  color: Color.fromARGB(255, 21, 101, 192),
                                  width: 2
                                )
                              ),
                              child: Icon(
                              Icons.directions_bus,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            );
                          })
                       ]
                     )
                   ],
                   )

               ),
             ),
           Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ElevatedButton(
                    child: Text("De-Select Bus", style: style),
                    onPressed: () {
                      
                        AdminWidget.dio.post("/driver/api/deSelectBus").then((value){
                          var data =value.data;
                          print(data);
                        
                          if(data['status']==-1){
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          _showMyDialog(msg: data['msg'], label: "Login Page", nextPage: login());
                          }else if(data['status']==1){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=> GetBus()));
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
                        // AdminWidget.dio.get("/driver/api/getRunningBusRoute").then((value) {
                        //   print(value);
                        // },).onError((error, stackTrace) {
                        //   print(error.toString());
                        // });
                        
                        
                        print(routeNumber.text);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => successpage2()));
                      
                    },
                    style: buttonstyle),
              )),
          ],
        ),
      )
    );
  }
}

