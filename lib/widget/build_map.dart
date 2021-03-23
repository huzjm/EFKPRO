import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class buildMap extends StatefulWidget {
  final double longitude;
  final double latitude;

  @override
  buildMap({this.longitude, this.latitude});

  State<StatefulWidget> createState() =>
      new _buildMapState(this.longitude, this.latitude);
}

class _buildMapState extends State<buildMap> {
  final double longitude;
  final double latitude;

  _buildMapState(this.longitude, this.latitude);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Last Known Location')),
        body: new FlutterMap(
            options: new MapOptions(
                center: new LatLng(latitude, longitude), minZoom: 10.0),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(markers: [
                new Marker(
                    width: 45.0,
                    height: 45.0,
                    point: new LatLng(latitude, longitude),
                    builder: (context) => new Container(
                          child: IconButton(
                              icon: Icon(Icons.location_on),
                              color: Colors.red,
                              iconSize: 45.0,
                              onPressed: () {
                                print('Marker tapped');
                              }),
                        ))
              ])
            ]));
  }
}
