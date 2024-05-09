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

Map<PlaceType, bool> filters = {
  PlaceType.restaurant: false,
  PlaceType.monument: false,
  PlaceType.nightclub: false,
  PlaceType.bar: false,
};

class FilterableMap extends StatefulWidget {
  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734);
  Symbol? lastAddedSymbol;

  TextEditingController nameController = TextEditingController();
  String? selectedType;

  @override
  void initState() {
    super.initState();
    _loadPointerImage();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    _loadImageFromAssets();
    _loadPointerImage();
  }

  void _toggleFilter(PlaceType type) {
    setState(() {
      filters[type] = !filters[type]!;
      _updateMap();
    });
  }

  Future<void> _loadImageFromAssets() async {
    final ByteData bytes = await rootBundle.load('lib/images/IconUser.png');
    final Uint8List list = bytes.buffer.asUint8List();
    mapController!.addImage('icon-user', list);
  }

  void _onStyleLoaded() {
    _loadSavedLocations();
    _requestLocationPermission();
  }

  Future<void> _loadPointerImage() async {
    try {
      final ByteData bytes = await rootBundle.load('lib/images/Puntero.png');
      final Uint8List list = bytes.buffer.asUint8List();
      await mapController!.addImage('puntero', list);
    } catch (e) {
      print('Error loading pointer image: $e');
    }
  }

  DateTime? lastTap;
  void _onMapClicked(Point<double> point, LatLng latLng) async {
    final DateTime now = DateTime.now();
    if (lastTap != null &&
        now.difference(lastTap!) < Duration(milliseconds: 500)) {
      lastAddedSymbol = await mapController?.addSymbol(SymbolOptions(
        geometry: latLng,
        iconImage: 'puntero',
        iconSize: 0.08,
      ));
      _showAddNewPlaceDialog(latLng);
      lastTap = null;
      lastTap = now;
    }
  }

  void _updateMap() {
    if (mapController == null) return;

    mapController!.clearSymbols();
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
        mapController!.addSymbol(SymbolOptions(
            geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
            iconImage: "${doc['type']}-icon"));
      }
    });
  }

  Future<void> _loadSavedLocations() async {
    if (mapController == null) return;

    FirebaseFirestore.instance
        .collection('locations')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        GeoPoint geoPoint = doc.data()['coordinates'];
        mapController!.addSymbol(SymbolOptions(
          geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
          iconImage:
              'puntero', // Asegúrate de que este icono está cargado en el mapa
          iconSize: 0.08,
        ));
      }
    });
  }

  Future<void> _showAddNewPlaceDialog(LatLng latLng) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nueva Ubicación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Nombre del lugar"),
                ),
                DropdownButton<String>(
                  value: selectedType,
                  hint: Text("Selecciona un tipo"),
                  isExpanded: true,
                  items: PlaceType.values.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.toString().split('.').last,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                if (lastAddedSymbol != null) {
                  mapController?.removeSymbol(lastAddedSymbol!);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar Ubicación'),
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedType != null) {
                  FirebaseFirestore.instance.collection('locations').add({
                    'name': nameController.text,
                    'type': selectedType,
                    'coordinates': GeoPoint(latLng.latitude, latLng.longitude)
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Todos los campos son obligatorios")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Retorna si los servicios no están habilitados.
    }

    // Solicitar permiso de ubicación.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Retorna si los permisos están permanentemente denegados.
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation(); // Obtiene la ubicación actual si los permisos están concedidos.
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _addUserLocationSymbol(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print("Failed to get current location: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: MapboxMap(
              accessToken:
                  "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: defaultCenter, zoom: 14),
              onStyleLoadedCallback: _onStyleLoaded,
              onMapClick: _onMapClicked,
            ),
          ),
          Row(
            children: PlaceType.values
                .map((type) => Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: filters[type] ?? false
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleFilter(type),
                        child: Text(type.toString().split('.').last),
                      ),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
