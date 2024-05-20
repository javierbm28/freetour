import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freetour/pagines/CrearNuevaUbicacion.dart';
import 'package:freetour/pagines/Filtros.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart';
import 'package:freetour/pagines/UbicacionesGuardadas.dart'; // Importa la nueva página
import 'package:freetour/pagines/Pagina_Inici.dart'; // Importa la página de inicio
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui';
import 'dart:math';

class FilterableMap extends StatefulWidget {
  final LatLng? initialPosition;

  FilterableMap({this.initialPosition});

  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734);
  Symbol? lastAddedSymbol;
  LatLng? lastTapLatLng;
  List<Category> activeFilters = categories;

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
    mapController!.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> _loadImageFromAssets() async {
    final ByteData bytes = await rootBundle.load('lib/images/IconUser.png');
    final Uint8List list = bytes.buffer.asUint8List();
    await mapController!.addImage('icon-user', list);
  }

  void _onStyleLoaded() {
    _requestLocationPermission();
    if (widget.initialPosition != null) {
      mapController?.animateCamera(CameraUpdate.newLatLng(widget.initialPosition!));
      _updateMap();
    }
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
    if (lastTap != null && now.difference(lastTap!) < Duration(milliseconds: 500)) {
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

  void _onSymbolTapped(Symbol symbol) async {
    LatLng? symbolLocation = symbol.options.geometry;
    if (symbolLocation == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('coordinates',
            isEqualTo: GeoPoint(symbolLocation.latitude, symbolLocation.longitude))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      String name = doc['name'];
      String subcategory = doc['subcategory'];

      _showLocationInfo(name, subcategory);
    }
  }

  void _showLocationInfo(String name, String subcategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subcategoría: $subcategory'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    for (var category in activeFilters) {
      for (var subcategory in category.subcategories.entries) {
        if (subcategory.value) {
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
    // No need to load saved locations initially
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _getCurrentLocation();
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
        iconSize: 0.1,
      ));
    }
  }

  void _applyFilters(List<Category> selectedCategories) {
    setState(() {
      activeFilters = selectedCategories;
    });
    _updateMap();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevenir que se pueda volver hacia atrás
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: MapboxMap(
                accessToken: "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: widget.initialPosition ?? defaultCenter, zoom: 14),
                onStyleLoadedCallback: _onStyleLoaded,
                onMapClick: _onMapClicked,
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Filtros(
                    onApplyFilters: (selectedCategories) {
                      _applyFilters(selectedCategories);
                    },
                  ),
                ),
              ),
              child: Icon(Icons.filter_list),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UbicacionesGuardadas(), // Navegar a la nueva página
                ),
              ),
              child: Icon(Icons.list),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaginaInici(), // Navegar a la página de inicio
                ),
              ),
              child: Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }
}






