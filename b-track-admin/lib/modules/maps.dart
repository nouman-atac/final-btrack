// ignore_for_file: unused_import, unused_element, unused_local_variable

import "dart:math";
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
// import 'package:mapbox_gl/mapbox_gl.dart' hide LatLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_api/mapbox_api.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  MapController _controller = MapController();
  double zoom = 15.0;

  String access_token =
      "pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA2d2E0eWYwMHpzM2NwZnA1NTFyamxkIn0.p87DFwS20cCG1Sa61WPo9g";
  String access =
      "pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg";
  String map_box_url =
      "https://api.mapbox.com/styles/v1/noumankhwaja2/cl054ae5l001m15o3jnps81ye/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MnZpODkwMWRqM2NveTRmaGZ3a3VkIn0.zitWlojsFpDmsrcgrBQdLg";
  String styleString =
      "mapbox://styles/noumankhwaja2/cl054ae5l001m15o3jnps81ye";

  LatLng _latlng = LatLng(19.03, 72.90);
  List<LatLng> points = [
    LatLng(19.03, 72.93),
    LatLng(19.13, 72.83),
    LatLng(19.23, 72.53),
    LatLng(19.53, 72.93),
    LatLng(19.03, 72.93),
  ];
  int index = 0;

  MapboxApi mapboxApi = MapboxApi(
      accessToken:
          "sk.eyJ1Ijoibm91bWFua2h3YWphMiIsImEiOiJjbDA1MzBodnMwc3psM2VxZG83OHZ6aTY3In0.VXgrtMszdfP6etwtsGzg0g");
  void _forwardGeocoding() {
    var response = mapboxApi.forwardGeocoding.request(
        language: 'en',
        fuzzyMatch: true,
        searchText: "Jacob Circle, Byculla",
        proximity: [points[0].latitude, points[0].longitude]).then((value) {
      //print(value.features![0].center);
      setState(() {
        this._latlng = LatLng(
            value.features![0].center![1], value.features![0].center![0]);
      });
    });
  }

  void _reverseGeocoding(LatLng latLng) {
    mapboxApi.reverseGeocoding.request(
      coordinate: [latLng.longitude, latLng.latitude],
      language: "en",
    ).then((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
            center: _latlng,
            zoom: zoom,
            onTap: (tap, latlng) {
              print(tap);
              print(latlng);
              _reverseGeocoding(latlng);

              this._latlng = latlng;
              setState(() {});
            }),
        layers: [
          TileLayerOptions(
              urlTemplate: map_box_url,
              additionalOptions: {'accessToken': this.access_token}),
          // MarkerLayerOptions(
          //   markers: <LatLng> [
          //     LatLng(19.03, 72.93),
          //       LatLng(19.13, 72.83),
          //       LatLng(19.23, 72.53),
          //       LatLng(19.53, 72.93),
          //       // LatLng(19.03, 72.93),
          //   ].map<Marker>((e){
          //     return Marker(
          //       point: e,
          //       builder: (context){
          //         return Icon(
          //           Icons.place,
          //           color: Colors.green,
          //           size: 20,
          //         );
          //       }
          //     );

          //   }).toList(),
          // ),
          // PolylineLayerOptions(
          //   polylines: [
          //     Polyline(points: [
          //       LatLng(19.03, 72.93),
          //       LatLng(19.13, 72.83),
          //       LatLng(19.23, 72.53),
          //       LatLng(19.53, 72.93),
          //       LatLng(19.03, 72.93),
          //     ],
          //     color: Colors.red
          //     )
          //   ]
          // ),
          // MarkerLayerOptions(
          //   markers: [
          //     Marker(
          //       point: _latlng,
          //       builder: (context){
          //         return Icon(
          //           Icons.my_location_rounded,
          //           size: 30,
          //         );
          //       }
          //     )
          //   ]
          // )
        ],
      ),
    );
  }
}
