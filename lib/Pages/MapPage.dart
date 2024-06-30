import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Maps extends StatefulWidget {
  final double long, alt;
  final String Name;
  const Maps(
      {required this.long, required this.alt, required this.Name, super.key});

  @override
  State createState() =>
      _MapsState(longt: this.long, alt: this.alt, Name: this.Name);
}

class _MapsState extends State<Maps> {
  final double longt, alt;
  final String Name;
  late GoogleMapController mapController;

  _MapsState({required this.longt, required this.Name, required this.alt});

  LatLng _setloc() {
    final LatLng _center = LatLng(alt, longt);
    return _center;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          elevation: 10,
          backgroundColor: const Color.fromARGB(255, 255, 208, 236),
          title:Row(children: [Text("$Name Current Location"),SizedBox(width:  20), Icon(Icons.location_history , size: 40)])
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _setloc(),
            zoom: 11.0,
          ),
          markers: {
            Marker(
                markerId: const MarkerId("Glasses Location"),
                position: _setloc())
          },
        ),

    );
  }
}
