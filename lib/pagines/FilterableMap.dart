import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freetour/pagines/CrearNuevaUbicacion.dart';
import 'package:freetour/pagines/Filtros.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart';
import 'package:freetour/pagines/UbicacionesGuardadas.dart';
import 'package:freetour/pagines/Pagina_Inici.dart';
import 'package:freetour/pagines/CrearNuevoEvento.dart';
import 'package:freetour/pagines/ListaEventos.dart';
import 'package:freetour/pagines/DetalleEvento.dart'; // Importar DetalleEvento
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:intl/intl.dart';

class FilterableMap extends StatefulWidget {
  final LatLng? initialPosition;
  final double zoomLevel;

  FilterableMap({this.initialPosition, this.zoomLevel = 14.0});
  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734);
  Symbol? lastAddedSymbol;
  LatLng? lastTapLatLng;
  List<Category> activeFilters = categories;
  bool showEvents = false; // Iniciar con eventos ocultos
  bool isMapLoaded = false;

  TextEditingController nameController = TextEditingController();
  String? selectedType;

  @override
  void initState() {
    super.initState();
    _loadPointerImage();
    _loadEventsImage();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    _loadImageFromAssets();
    _loadPointerImage();
    _loadEventsImage();
    mapController!.onSymbolTapped.add(_onSymbolTapped);
    if (widget.initialPosition != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          widget.initialPosition!, widget.zoomLevel));
      _addEventSymbol(widget.initialPosition!);
    }
    setState(() {
      isMapLoaded = true;
    });
  }

  Future<void> _loadImageFromAssets() async {
    final ByteData bytes = await rootBundle.load('lib/images/IconUser.png');
    final Uint8List list = bytes.buffer.asUint8List();
    await mapController!.addImage('icon-user', list);
  }

  void _onStyleLoaded() {
    _requestLocationPermission();
    if (widget.initialPosition != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          widget.initialPosition!, widget.zoomLevel)); // Usar zoomLevel
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

  Future<void> _loadEventsImage() async {
    try {
      final ByteData bytes = await rootBundle.load('lib/images/evento.png');
      final Uint8List list = bytes.buffer.asUint8List();
      await mapController!.addImage('evento', list);
    } catch (e) {
      print('Error loading event image: $e');
    }
  }

  DateTime? lastTap;
  void _onMapClicked(Point<double> point, LatLng latLng) async {
    final DateTime now = DateTime.now();
    if (lastTap != null &&
        now.difference(lastTap!) < Duration(milliseconds: 500)) {
      lastTapLatLng = latLng;
      _showCreationDialog(context, latLng);
      lastTap = null;
    } else {
      lastTap = now;
    }
  }

  void _showCreationDialog(BuildContext context, LatLng latLng) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Qué quieres registrar?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Agregar una ubicación'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CrearNuevaUbicacion(
                      latLng: latLng,
                      onLocationSaved: _onLocationSaved,
                    ),
                  ));
                },
              ),
              ListTile(
                title: Text('Agregar un evento'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CrearNuevoEvento(
                      latLng: latLng,
                    ),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSymbolTapped(Symbol symbol) async {
    LatLng? symbolLocation = symbol.options.geometry;
    if (symbolLocation == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('coordinates',
            isEqualTo:
                GeoPoint(symbolLocation.latitude, symbolLocation.longitude))
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      String eventId = doc.id;
      String title = doc['title'];
      DateTime dateTime = (doc['dateTime'] as Timestamp).toDate();
      String imageUrl = doc['imageUrl'];

      _showEventInfo(eventId, title, dateTime, imageUrl);
    }
  }

  void _showEventInfo(
      String eventId, String title, DateTime dateTime, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat.yMd().add_jm().format(dateTime)),
              SizedBox(height: 10),
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ver evento'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleEvento(eventId: eventId),
                  ),
                );
              },
            ),
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

  void _addEventSymbol(LatLng latLng) {
    if (mapController != null && isMapLoaded) {
      setState(() {
        mapController?.addSymbol(SymbolOptions(
          geometry: latLng,
          iconImage: 'evento',
          iconSize: 0.1,
        ));
      });
    } else {
      print('MapController is not initialized');
    }
  }

  void _updateMap() {
    if (mapController == null) return;

    mapController!.clearSymbols();
    // Cargar ubicaciones
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

    // Cargar eventos
    if (showEvents) {
      FirebaseFirestore.instance
          .collection('events')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          GeoPoint geoPoint = doc['coordinates'];
          mapController!.addSymbol(SymbolOptions(
            geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
            iconImage: 'evento', // Asegúrate de cargar un ícono de evento
            iconSize: 0.1,
          ));
        }
      });
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

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
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

  void _toggleEventsVisibility() {
    setState(() {
      showEvents = !showEvents;
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
                accessToken:
                    "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: widget.initialPosition ?? defaultCenter,
                    zoom: widget.zoomLevel), // Usar zoomLevel
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
                  builder: (context) =>
                      UbicacionesGuardadas(), // Navegar a la nueva página
                ),
              ),
              child: Icon(Icons.list),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PaginaInici(), // Navegar a la página de inicio
                ),
              ),
              child: Icon(Icons.home),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _toggleEventsVisibility,
              child: Icon(showEvents ? Icons.visibility : Icons.visibility_off),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ListaEventos(), // Navegar a la página de eventos
                ),
              ),
              child: Icon(Icons.event),
            ),
          ],
        ),
      ),
    );
  }
}


