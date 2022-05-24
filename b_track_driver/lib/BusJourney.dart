
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'package:b_track_driver/AdminWidget.dart';
import 'package:b_track_driver/SuccessfulLogin.dart';
import 'package:b_track_driver/textfieldstyle.dart';
import 'package:b_track_driver/login.dart';
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

class BusJourney extends StatefulWidget {
  String? msg;
  BusJourney({Key? key,this.msg}):super(key: key);
  @override
  _BusJourney createState() => _BusJourney();
}

class _BusJourney extends State<BusJourney> {
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
  double previousLatitude = 18.967928,previousLongitude=72.831404;

  int mode=0,loaded=0,_buttonEnabled=1;
  LatLng initialStopMarker=LatLng(18.967928, 72.831404);
  var routeData;
  int startFlag=0,endFlag=0;

  List<LatLng> points=[];
  List<Marker> busStopMarkers=[];
  List<String> buttonText=['Start Journey',"Stop Journey"];
  Timer? _timer;


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
              _timer?.cancel();
              location.onLocationChanged.listen(null);
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

Widget makerContainer(String label){
  return Container(
          width: 20,
          height: 20,
          child:  Center(
            child:Text(
              label,
            style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold
              ),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black,
            boxShadow: const[
              BoxShadow(
                color: Color.fromARGB(255, 66, 66, 66),
                blurStyle: BlurStyle.outer,
                blurRadius: 3
              )
            ]
          ),
        );
}

void createRoute(List<dynamic> route){
  if(points.length>0) return;
  int i=0;
  int len=route.length;
  print("In route");
  while(i<len){
    this.points.add(LatLng(double.parse(route[i]['latitude']),double.parse(route[i]['longitude'])));
    i++;
  }
  // print(this.points);
}
void createBusStopMarkers(Map<dynamic,dynamic> data){
  if(busStopMarkers.length>0) return;
  List<dynamic> stops=data['stops'];

  int i=0;
  int len=stops.length;
  while(i<len){
    // if(routeData['busStopIds'])
    print("${stops[i]['busStopId']}    ${data['busStopIds'][0]}");
    if(stops[i]['busStopId']==data['busStopIds'][0])
    {
      busStopMarkers.add(Marker(
      point: LatLng(double.parse(stops[i]['coordinates']['latitude']),double.parse(stops[i]['coordinates']['longitude'])),
      builder: (context){
        return Tooltip(
          message: "Stop Name",
          //message: "${stops[i]['busStopName']} \n ${stops[i]['landmark']}, Pin- ${stops[i]['pincode']}",
          child: makerContainer("Start"),
        );
        
      }));
      }
      else if(stops[i]['busStopId']==data['busStopIds'][len-1])
    {
      busStopMarkers.add(Marker(
      point: LatLng(double.parse(stops[i]['coordinates']['latitude']),double.parse(stops[i]['coordinates']['longitude'])),
      builder: (context){
        return Tooltip(
          message: "Stop Name",
          //message: "${stops[i]['busStopName']} \n ${stops[i]['landmark']}, Pin- ${stops[i]['pincode']}",
          child: makerContainer("Stop"),
        );
        
      }));
      }
    else
      {busStopMarkers.add(Marker(
        point: LatLng(double.parse(stops[i]['coordinates']['latitude']),double.parse(stops[i]['coordinates']['longitude'])),
        builder: (context){
          return const Icon(
            Icons.place,
            color: Colors.black,
          );
        }));}
  // print(stops[i]);
  i++;
  }
  print(busStopMarkers);
  loaded=1;
}

@override
void initState(){
  super.initState();
  
   AdminWidget.dio.get("/driver/api/getRouteDetails").then(((value) {
      var data = value.data;
      // print(value.data);
      if(data['status']==-1){
        _showMyDialog(msg: data['msg'], label: "Session Expired", nextPage: login());
      }
      else if(data['status']==1){

        var newData=data['data'][0];
        // print(newData['stops']);
        routeData=newData;
        createRoute(newData['routeGeometry']);
        createBusStopMarkers(newData);

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
              loaded=1;

          marker = LatLng(previousLatitude,previousLongitude);
        });
          _mapController.move(marker, 14);
           location.enableBackgroundMode(enable: true);
  location.onLocationChanged.listen((LocationData currentLocation) {
    previousLatitude=currentLocation.latitude!;
    previousLongitude= currentLocation.longitude!;
  if(mounted){


  setState(() {
        // loaded=1;

    marker = LatLng(previousLatitude,previousLongitude);
  });
  print(previousLatitude);
  print(previousLongitude);
  print(currentLocation.latitude!);
  print(currentLocation.longitude!);
  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(currentLocation.toString())));
  // _mapController.move(marker, 15);
  }
 
  
});

  }));
        
        setState(() {
          
        });

      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
      }
    }));
   

  
}
  

  
  
 

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    location.onLocationChanged.listen(null);
    
    _timer?.cancel();

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
                textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ))),
        backgroundColor: Color(0xfffb713c),
        elevation: 0,
      ),
      body:Container(
        padding: EdgeInsets.fromLTRB(0, 20,0, 0),
        child: Column(
          children: [
          Center(
               child: Container(
                //  color: Colors.white,
                 width: 320,
                 height: 560,
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
                     
                     if(loaded==1)
                     MarkerLayerOptions(
                       markers: [
                         Marker(
                          point: marker,
                          builder: (context){
                            return Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
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
                          }),
                         
                            ...busStopMarkers
                       ]
                     ),
                     PolylineLayerOptions(
                       polylines:[
                         
                         Polyline(
                           points: this.points,
                           color: Colors.black,
                           strokeWidth: 3
                         )
                       ]
                     ),
                   ],
                   )

               ),
             ),
           Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ElevatedButton(
                    child: Text(buttonText[mode], style: style),
                    onPressed: () {
                      if(routeData!=null){
                        if(mode==0){
                          

                     AdminWidget.dio.post("/driver/api/startJourney",data:{

                       'latitude':previousLatitude,"longitude":previousLongitude,"startStopId":routeData['busStopIds'][0]
                     }).then((value){
                       var data=value.data;
                       print(value.data);
                        if(data['status']==-1){
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          _showMyDialog(msg: data['msg'], label: "Login Page", nextPage: login());
                          }else if(data['status']==1){
                            // Navigator.push(context, MaterialPageRoute(builder: (builder)=> BusJourney()));
                            print(data["data"]);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'].toString())));

                            _timer = Timer.periodic(Duration(seconds: 15), (timer) {

                              if(mounted){
                                AdminWidget.dio.post("/driver/api/updateJourney",data:{"latitude":previousLatitude,"longitude":previousLongitude}).then((value){
                                var updateData=value.data;
                                if(updateData['status']==-1){
                                  _showMyDialog(msg: updateData['msg'], label: "Session Expired", nextPage: login());
                                }
                                else if(updateData['status']==1){
                                 var newStops=updateData['updatedBusStops'];
                                 if(newStops[newStops.length-1]['reachedStatus']==true){
                                   setState(() {
                                     _buttonEnabled=1;
                                   });
                                 }
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(updateData['msg'])));
                                }


                              }).onError((error, stackTrace){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                              } );
                              }

                              
                             });
                             setState(() {
                               mode=1;
                               _buttonEnabled=0;
                             });
                          }
                          else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                          }
                     }).onError((error, stackTrace){
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                     });
                    }
                    else{
                      if(_buttonEnabled==0){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Complete the Journey")));
                      }
                      else{
                        _timer?.cancel();
                        AdminWidget.dio.post("/driver/api/completeJourney").then((value){
                          var data=value.data;
                          if(data['status']==1){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));
                            
                            Navigator.pop(context);
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['msg'])));

                          }
                        });
                     

                      }
                    }
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading...")));
                      }
                    

                    },
                    style: ElevatedButton.styleFrom(
                            fixedSize: Size(150, 40),
                            primary: _buttonEnabled==1?Color(0xfffb713c):Color.fromARGB(255, 93, 92, 92),
                            elevation: 15,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              //side: BorderSide(color: Colors.grey.shade800),
                            ))
),
              )),
          ],
        ),
      )
    );
  }
}
