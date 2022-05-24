// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unnecessary_null_comparison, deprecated_member_use, prefer_collection_literals, prefer_const_constructors

import 'package:b_track/registration.dart';
import 'AdminWidget.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'User.dart';
import 'Services.dart';
import 'NavBar.dart';

final style1 = GoogleFonts.rowdies(
    textStyle: TextStyle(
  color: Color(0xff343b71),
  fontSize: 15,
));

final style2 = GoogleFonts.roboto(
    textStyle: TextStyle(
  color: Color(0xff343b71),
  fontSize: 15,
));

class UserFilterDemo extends StatefulWidget {
  UserFilterDemo() : super();

  @override
  UserFilterDemoState createState() => UserFilterDemoState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class UserFilterDemoState extends State<UserFilterDemo> {
  // https://jsonplaceholder.typicode.com/users

  final _debouncer = Debouncer(milliseconds: 500);
  List<User> users = [];
  List<User> filteredUsers = [];
  TextEditingController search= TextEditingController();

  @override
  void initState() {
    super.initState();
    Services.getUsers().then((usersFromServer) {
      setState(() {
        users = usersFromServer;
        filteredUsers = users;
      });
    });
  }

  List<Map> buses=[
    // {"busNumber":"Route No-2 -> Bus- MH01BZ4140","subTitle":"Duration: 20 mins  Distance: 3.35km  Stops Left: 3"},
    // {"busNumber":"Route No-2 -> Bus- MH01dZ2670","subTitle":"Duration: 25 mins  Distance: 4.79km  Stops Left: 5"},
    // {"busNumber":"Route No-2 -> Bus- MH01BZ4140","subTitle":"Duration: 30 mins  Distance: 5.12km  Stops Left: 6"}
  ];

  int toMins(double seconds){
    return (seconds/60).ceil();
  }

  String toKms(double dist)=> (dist/1000).toStringAsPrecision(2);

  void updatePage(List<dynamic> data){
    buses=[];
    var newData=data[0]['busesRunning'];
    int len=newData.length;
    print("Hello: "+len.toString());
    print(newData);
    for(int x=0;x<len; x++){
      double distance=0,time=0;
      int counter=0;
      int lenn=newData[x]['busStops'].length;

      for(int y=0;y<3;y++){

        distance+=double.parse(newData[x]['busStops'][y]['distanceRequired'].toString());
        time+=double.parse(newData[x]['busStops'][y]['timeRequired'].toString());

        if(newData[x]['busStops'][y]['reachedStatus']==false)
        {
          counter++;
          }
      }
      buses.add(
        {
          "busNumber":"Route No-${data[0]['busRouteNumber'].toString()} -> Bus - ${newData[x]['busRegistrationNumber'].toString()}",
          "subTitle":"Duration: ${toMins(time).toString()} mins  Distance:${toKms(distance)}km   Stops Left:${counter.toString()}",
          "busRouteNumber":data[0]['busRouteNumber'].toString(),
          "journeyId":newData[x]['journeyId'].toString()
        }
      );
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff343b71),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.grid_view_rounded),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NavBar()));
          },
        ),
        title: Center(
          child: Image.asset(
            'assets/images/logo_name.png',
            height: 60,
            width: 200,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share),
            color: Colors.white,
          )
        ],
        backgroundColor: Color(0xff343b71),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: search,
            style: style,
            cursorColor: Colors.white,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15.0),
                fillColor: Colors.white,
                hintText: 'Search Bus No here...',
                hintStyle: TextStyle(fontSize: 15, color: Colors.white)),
            onChanged: (string) {
              // _debouncer.run(() {
              //   setState(() {
              //     filteredUsers = users
              //         .where((u) => (u.name
              //                 .toLowerCase()
              //                 .contains(string.toLowerCase()) ||
              //             u.email.toLowerCase().contains(string.toLowerCase())))
              //         .toList();
              //   });
              // });
            },
          ),
          ElevatedButton(
                    child: Text("Login", style: style),
                    onPressed: () {
                      if (search.text.isNotEmpty) {
                       
                       AdminWidget.dio.post("/user/api/getRunningRoutes",data:{ 
                          "busRouteNumber": search.text, 
                          }).then((value){
                          var data =value.data;
                          print(data);
                          if(data['status']==-1){
                            
                              
                              var snackBar= SnackBar(content: Text(data['msg']));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => login()));
                            
                            
                          }
                          else if(data['status']==1){
                            updatePage(data['data']);
                            
                            // print(data['data'].length);
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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0), 
              itemCount: buses.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  child: Center(
                      child: ListTile(
                    title: Text(buses[index]['busNumber'], style: style1),
                    subtitle: Text(
                      buses[index]['subTitle'].toLowerCase(),
                      style: style2,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RealTimeLocation(busRouteNumber: buses[index]['busRouteNumber'],journeyId:  buses[index]['journeyId'],)));
                    },
                  )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class RealTimeLocation extends StatefulWidget {
  RealTimeLocation({ Key? key,required this.busRouteNumber,required this.journeyId }) : super(key: key);
  String busRouteNumber,journeyId;

  @override
  State<RealTimeLocation> createState() => _RealTimeLocationState();
}

class _RealTimeLocationState extends State<RealTimeLocation> {

  late MapController _mapController;
  LatLng center= LatLng(18.967928, 72.831404);
  LatLng marker= LatLng(18.967928, 72.831404);
  LatLng busMarker= LatLng(18.967928, 72.831404);
  Location location=Location();
  // TextEditingController password=TextEditingController();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  var previousLatitude = 18.967928,previousLongitude=72.831404;

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
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (context) => nextPage));
              _timer?.cancel();
            },
          ),
        ],
      );
    },
  );
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

List<Map> buses=[
    {"busNumber":"Saatrasta Bus Stop","subTitle":" Reached"},
    {"busNumber":"Nouman's House","subTitle":"Reached"},
    {"busNumber":"Sundar Gali Stop","subTitle":"Duration: 2 mins  Distance: 0.37km "},
    {"busNumber":"Richardson And Cruddos","subTitle":"Duration: 10 mins  Distance: 1.6km "},
  ];


void handleData(var data){
buses=[];
  busMarker=LatLng(data['busesRunning'][0]['currentLocation']['latitude'],data['busesRunning'][0]['currentLocation']['longitude']);
  // print("Current: "+data['busesRunning'][0]['currentLocation']['latitude']);
  int j=0;
  for(var stop in data['busesRunning'][0]['busStops']){

    if(stop['reachedStatus']==true){
      buses.add({
        'busNumber':"Stop ${j}",
        "subTitle":"Reached"
      });
    }
    else{
      buses.add({
        'busNumber':"Stop ${j}",
        // "subTitle":"Reached"

        "subTitle":"Duration: ${toMins(double.parse(stop['timeRequired'].toString())).toString()} mins  Distance: ${toKms(double.parse(stop['distanceRequired'].toString()))} kms "
      });
      j++;
    }

  }
  setState(() {
    
  });
}

  int toMins(double seconds){
    return (seconds/60).ceil();
  }

  String toKms(double dist)=> (dist/1000).toStringAsPrecision(2);
void initState(){
 

 super.initState();
  
   AdminWidget.dio.post("/user/api/getRouteDetails",data:{"busRouteNumber":widget.busRouteNumber}).then(((value) {
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

        _timer=Timer.periodic(Duration(seconds: 10),(timer){

          AdminWidget.dio.post("/user/api/getJourney",data:{"busRouteNumber":widget.busRouteNumber,"journeyId":widget.journeyId}).then((value){
            var data=value.data;
            print(data.runtimeType);
            print(widget.journeyId);
            // print(data['data']['busesRunning']);
            handleData(data['data']);
            
          }).onError((error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
          });

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

Widget markerContainer(String label){
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

}

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _timer?.cancel();
    location.onLocationChanged.listen(null);
  }


  @override
  Widget build(BuildContext context) {
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
        title: Center(
          child: Image.asset(
            'assets/images/logo_name.png',
            height: 60,
            width: 200,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share),
            color: Colors.white,
          )
        ],
        backgroundColor: Color(0xff343b71),
        elevation: 0,
      ),
      body: SlidingUpPanel(
        body: Center(
          child: Container(
            
            height: 700,
            width: double.infinity,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
                bottomLeft: const Radius.circular(10.0),
                bottomRight: const Radius.circular(10.0),
              ),border: Border.all(width: 3,color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2.0,
                  spreadRadius: 3.0,
                )
              ],
            ),
            child: FlutterMap(
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
                          point: busMarker,
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
                          Marker(point: marker, builder: (context){
                            return Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Color.fromARGB(255, 31, 139, 227),width: 9)
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
        panel: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 10,
            backgroundColor: Color.fromARGB(255, 78, 78, 79),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: buses.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  child: Center(
                      child: ListTile(
                    title: Text(buses[index]['busNumber'], style: style1),
                    subtitle: Text(
                      buses[index]['subTitle'],
                      style: style2,
                    ),
                    onTap: () {},
                  )),
                );
              },
            ),
          ),
        )
      )
      
    );
  }
}


// longitude
// "72.82661673207885"
// latitude
// "18.980748580709907"

// LatLng(18.980748580709907,72.82661673207885),
// LatLng(18.978771266983614,72.82854062261617),
// LatLng(18.975608648740515,72.83116930474934),
// LatLng(18.96597207818258,72.83261661490802),

// latitude
// "18.978771266983614"
// longitude
// "72.82854062261617"

// latitude
// "18.975608648740515"
// longitude
// "72.83116930474934"

// longitude
// "72.83261661490802"
// latitude
// "18.96597207818258"