import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freetour/pagines/CrearNuevaUbicacion.dart';
import 'package:freetour/pagines/Filtros.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui';
import 'dart:math';

class FilterableMap extends StatefulWidget {
  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734);
  Symbol? lastAddedSymbol;
  LatLng? lastTapLatLng;

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

  Future<void> _loadImageFromAssets() async {
    final ByteData bytes = await rootBundle.load('lib/images/IconUser.png');
    final Uint8List list = bytes.buffer.asUint8List();
    await mapController!.addImage('icon-user', list);
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
      lastTapLatLng = latLng;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CrearNuevaUbicacion(
          latLng: latLng,
          onLocationSaved: _onLocationSaved,
        ),
      ));
      lastTap = null;
    } else {
      lastTap = now;
    }
  }

  void _onLocationSaved(LatLng latLng) {
    setState(() {
      mapController?.addSymbol(SymbolOptions(
        geometry: latLng,
        iconImage: 'puntero',
        iconSize: 0.08,
      ));
    });
  }

  void _updateMap() {
    if (mapController == null) return;

    mapController!.clearSymbols();
    for (var category in categories) {
      for (var subcategory in category.subcategories.entries) {
        if (subcategory.value) {
          // Check if subcategory is visible
          FirebaseFirestore.instance
              .collection('locations')
              .where('category', isEqualTo: category.name)
              .where('subcategory', isEqualTo: subcategory.key)
              .get()
              .then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              GeoPoint geoPoint = doc['coordinates'];
              mapController!.addSymbol(SymbolOptions(
                geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
                iconImage: 'puntero',
                iconSize: 0.08,
              ));
            }
          });
        }
      }
    }
  }

  Future<void> _loadSavedLocations() async {
    if (mapController == null) return;

    FirebaseFirestore.instance.collection('locations').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        GeoPoint geoPoint = doc.data()['coordinates'];
        mapController!.addSymbol(SymbolOptions(
          geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
          iconImage: 'puntero',
          iconSize: 0.08,
        ));
      }
    });
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
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
              accessToken: "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: defaultCenter, zoom: 14),
              onStyleLoadedCallback: _onStyleLoaded,
              onMapClick: _onMapClicked,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Filtros(
              onApplyFilters: (selectedCategories) {
                // Lógica para aplicar filtros
              },
            ),
          ),
        ),
        child: Icon(Icons.filter_list),
      ),
    );
  }
}

