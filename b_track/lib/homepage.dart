// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, non_constant_identifier_names, avoid_types_as_parameter_names, unused_local_variable, avoid_init_to_null

import 'package:b_track/BusNoSearch.dart' hide LatLng;
import 'package:b_track/NavBar.dart';
import 'package:b_track/login.dart';
import 'package:b_track/AdminWidget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
  // AdminWidget.dio.get("/driver/api/").then(((value) {
  //     var data = value.data;
  //     if(data['status']==-1){
  //       Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
  //     }
  //   }));
   

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
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          Container(
            height: 70,
            child: Padding(
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: ElevatedButton(
                child: Text(
                  "Search by Bus No",
                  style: GoogleFonts.rowdies(
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserFilterDemo()));
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 40),
                  primary: Color(0xff343b71),
                  elevation: 10,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
          Container(
            height: 500,
            width: double.infinity,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
                bottomLeft: const Radius.circular(10.0),
                bottomRight: const Radius.circular(10.0),
              ),
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
        ],
      )),
    );
  }
}

