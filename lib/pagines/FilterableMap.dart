import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui'; 
import 'dart:math'; 

enum PlaceType {
  restaurant,
  monument,
  nightclub,
  bar,
}

class FilterableMap extends StatefulWidget {
  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734); // Barcelona coordinates

  Map<PlaceType, bool> filters = {
    PlaceType.restaurant: false,
    PlaceType.monument: false,
    PlaceType.nightclub: false,
    PlaceType.bar: false,
  };

  DateTime? lastTap;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _onMapCreated(MapboxMapController controller) async {
    mapController = controller;
    await _loadImageFromAssets();
  }

  Future<void> _loadImageFromAssets() async {
    final ByteData bytes = await rootBundle.load('lib/images/IconUser.png');
    final Uint8List list = bytes.buffer.asUint8List();
    mapController!.addImage('icon-user', list);
  }

  void _onMapClicked(Point<double> point, LatLng latLng) {
    final DateTime now = DateTime.now();
    if (lastTap != null && now.difference(lastTap!) < Duration(milliseconds: 500)) {
      _showAddNewPlaceDialog(latLng);
    } else {
      lastTap = now;
    }
  }

  Future<void> _showAddNewPlaceDialog(LatLng latLng) async {
    // Example implementation here
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _addUserLocationSymbol(defaultCenter); // Use default center if services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _addUserLocationSymbol(defaultCenter);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      await _addUserLocationSymbol(defaultCenter);
      return;
    }

    // Obtaining current location and adding a symbol on the map
    Position position = await Geolocator.getCurrentPosition();
    await _addUserLocationSymbol(LatLng(position.latitude, position.longitude));
  }

  Future<void> _addUserLocationSymbol(LatLng latLng) async {
    if (mapController != null) {
      await mapController!.addSymbol(SymbolOptions(
        geometry: latLng,
        iconImage: 'icon-user',
        iconSize: 0.1, // Fixed icon size regardless of zoom level
      ));
    }
  }

  void _toggleFilter(PlaceType type) {
    setState(() {
      filters[type] = !filters[type]!;
      _updateMap();
    });
  }

  void _updateMap() {
    mapController?.clearSymbols();
    FirebaseFirestore.instance
      .collection('locations')
      .where('type',
          isEqualTo: filters.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key.toString().split('.').last)
              .join(','))
      .get()
      .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          GeoPoint geoPoint = doc['coordinates'];
          mapController?.addSymbol(SymbolOptions(
              geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
              iconImage: "${doc['type']}-icon"));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: MapboxMap(
              accessToken: "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: defaultCenter, zoom: 14),
              onMapClick: _onMapClicked,
            ),
          ),
          Row(
            children: PlaceType.values.map((type) => Expanded(
              child: TextButton(
                onPressed: () => _toggleFilter(type),
                child: Text(type.toString().split('.').last),
                style: TextButton.styleFrom(
                  backgroundColor: filters[type] ?? false ? Colors.blue : Colors.grey,
                ),
              ),
            )).toList(),
          )
        ],
      ),
    );
  }
}
