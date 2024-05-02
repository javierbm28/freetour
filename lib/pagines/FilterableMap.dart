import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
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
  final LatLng center =
      const LatLng(40.730610, -73.935242);

  Map<PlaceType, bool> filters = {
    PlaceType.restaurant: false,
    PlaceType.monument: false,
    PlaceType.nightclub: false,
    PlaceType.bar: false,
  };

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    // Aquí puedes asegurarte de que el accessToken se establece correctamente.
  }

  // Modifica esta función para aceptar ambos parámetros
  void _onMapClicked(Point<double> point, LatLng latLng) async {
    // Puedes decidir si utilizar el `Point<double>` dependiendo de tus necesidades
    _addNewLocation(latLng);
  }

  void _addNewLocation(LatLng latLng) async {
    String name = "Nuevo Sitio";
    PlaceType type = PlaceType.restaurant;

    Symbol symbol = await mapController!.addSymbol(SymbolOptions(
      geometry: latLng,
      iconImage: "custom-icon",
      textField: name,
      textOffset: Offset(0, -2),
    ));

    final docRef =
        await FirebaseFirestore.instance.collection('locations').add({
      'name': name,
      'type': type.toString().split('.').last,
      'coordinates': GeoPoint(latLng.latitude, latLng.longitude)
    });

    print("Ubicación guardada con ID: ${docRef.id}");
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
    return Column(
      children: <Widget>[
        Expanded(
          child: MapboxMap(
            accessToken:
                "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: center, zoom: 14),
            onMapClick:
                _onMapClicked, // Pasa la función con ambos parámetros aquí
          ),
        ),
        Row(
          children: PlaceType.values
              .map((type) => Expanded(
                    child: TextButton(
                      onPressed: () => _toggleFilter(type),
                      child: Text(type.toString().split('.').last),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            filters[type] ?? false ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}
