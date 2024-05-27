import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freetour/pagines/CrearNuevaUbicacion.dart';
import 'package:freetour/pagines/Filtros.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart';
import 'package:freetour/pagines/UbicacionesGuardadas.dart';
import 'package:freetour/pagines/CrearNuevoEvento.dart';
import 'package:freetour/pagines/ListaEventos.dart';
import 'package:freetour/pagines/DetalleEvento.dart';
import 'package:freetour/pagines/Pagina_Inici.dart'; // Importa tu página de inicio
import 'package:freetour/pagines/verPerfil.dart'; // Importa tu página de perfil
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:intl/intl.dart';

class FilterableMap extends StatefulWidget {
  final LatLng? initialPosition;
  final double zoomLevel;
  final String? activeCategory;
  final String? activeSubcategory;

  FilterableMap({this.initialPosition, this.zoomLevel = 14.0, this.activeCategory, this.activeSubcategory});
  
  @override
  _FilterableMapState createState() => _FilterableMapState();
}

class _FilterableMapState extends State<FilterableMap> {
  MapboxMapController? mapController;
  final LatLng defaultCenter = const LatLng(41.3851, 2.1734);
  LatLng? lastTapLatLng;
  List<Category> activeFilters = categories;
  bool showEvents = true; // Asegúrate de que esto esté activado por defecto
  bool showLocations = true; // Asegúrate de que esto esté activado por defecto
  bool isMapLoaded = false;
  bool addingLocation = false;
  bool addingEvent = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  DateTime? lastButtonTap;

  @override
  void initState() {
    super.initState();
    _loadPointerImage();
    _loadEventsImage();
    if (widget.activeCategory != null && widget.activeSubcategory != null) {
      _applyFilterFromConstructor(widget.activeCategory!, widget.activeSubcategory!);
    }
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
    _updateMap(); // Mueve esto aquí para asegurarte de que el mapa esté cargado antes de actualizar
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
          widget.initialPosition!, widget.zoomLevel));
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

  void _onMapClicked(Point<double> point, LatLng latLng) {
    if (addingLocation) {
      _navigateToAddLocation(latLng);
    } else if (addingEvent) {
      _navigateToAddEvent(latLng);
    }
  }

  void _navigateToAddLocation(LatLng latLng) {
    setState(() {
      addingLocation = false;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CrearNuevaUbicacion(
        latLng: latLng,
        onLocationSaved: _onLocationSaved,
      ),
    ));
  }

  void _navigateToAddEvent(LatLng latLng) {
    setState(() {
      addingEvent = false;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CrearNuevoEvento(latLng: latLng),
    ));
  }

  void _onSymbolTapped(Symbol symbol) async {
    if (currentUser == null) return;

    LatLng? symbolLocation = symbol.options.geometry;
    if (symbolLocation == null) return;

    // Verificar si es un evento o una ubicación
    if (symbol.options.iconImage == 'evento') {
      // Obtener y mostrar la información del evento
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
    } else if (symbol.options.iconImage == 'puntero') {
      // Obtener y mostrar la información de la ubicación
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .where('coordinates',
              isEqualTo:
                  GeoPoint(symbolLocation.latitude, symbolLocation.longitude))
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        String title = doc['name'];
        String category = doc['category'];
        String subcategory = doc['subcategory'];
        String imageUrl = doc['imageUrl'];

        _showLocationInfo(title, category, subcategory, imageUrl);
      }
    }
  }

  void _showEventInfo(
      String eventId, String title, DateTime dateTime, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Fecha: ${DateFormat.yMd().format(dateTime)}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Hora: ${DateFormat.jm().format(dateTime)}'),
                ),
                SizedBox(height: 10),
                if (imageUrl.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Ver evento'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleEvento(eventId: eventId),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLocationInfo(
      String title, String category, String subcategory, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('$category - $subcategory'),
                ),
                SizedBox(height: 10),
                if (imageUrl.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cerrar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          iconSize: 0.08,
        ));
      });
    } else {
      print('MapController is not initialized');
    }
  }

  void _applyFilterFromConstructor(String category, String subcategory) {
    setState(() {
      for (var cat in activeFilters) {
        if (cat.name == category) {
          for (var sub in cat.subcategories.keys) {
            cat.subcategories[sub] = sub == subcategory;
          }
        } else {
          for (var sub in cat.subcategories.keys) {
            cat.subcategories[sub] = false;
          }
        }
      }
    });
  }

  Future<void> _updateMap() async {
    if (mapController == null || !isMapLoaded) return;

    try {
      await mapController!.clearSymbols();
    } catch (e) {
      print('Error clearing symbols: $e');
      return; // Exit the method if clearing symbols failed
    }

    // Cargar ubicaciones
    if (showLocations) {
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

    // Cargar eventos
    if (showEvents) {
      DateTime now = DateTime.now();
      FirebaseFirestore.instance
          .collection('events')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          DateTime eventDateTime = (doc['dateTime'] as Timestamp).toDate();
          if (eventDateTime.isAfter(now)) {
            GeoPoint geoPoint = doc['coordinates'];
            mapController!.addSymbol(SymbolOptions(
              geometry: LatLng(geoPoint.latitude, geoPoint.longitude),
              iconImage: 'evento',
              iconSize: 0.08,
            ));
          }
        }
      });
    }
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

  void _toggleVisibility() {
    setState(() {
      showEvents = !showEvents;
      showLocations = !showLocations;
    });
    _updateMap();
  }

  void _toggleAddingLocation() {
    setState(() {
      addingLocation = !addingLocation;
      addingEvent = false;
    });
  }

  void _toggleAddingEvent() {
    setState(() {
      addingEvent = !addingEvent;
      addingLocation = false;
    });
  }

  bool _isDoubleTapOnButton() {
    final DateTime now = DateTime.now();
    if (lastButtonTap != null &&
        now.difference(lastButtonTap!) < Duration(milliseconds: 500)) {
      lastButtonTap = now;
      return true;
    }
    lastButtonTap = now;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Discovery'),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para acceder al mapa.'),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Discovery'),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PaginaInici(),
                ),
              );
            },
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('Agregar Ubicación'),
              onPressed: addingEvent
                  ? null
                  : () {
                      _toggleAddingLocation();
                    },
            ),
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('Agregar Evento'),
              onPressed: addingLocation
                  ? null
                  : () {
                      _toggleAddingEvent();
                    },
            ),
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: addingLocation || addingEvent
                  ? null
                  : () {
                      if (_isDoubleTapOnButton()) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Filtros(
                            onApplyFilters: (selectedCategories) {
                              _applyFilters(selectedCategories);
                            },
                          ),
                        ),
                      );
                    },
            ),
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: addingLocation || addingEvent
                  ? null
                  : () {
                      if (_isDoubleTapOnButton()) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UbicacionesGuardadas(),
                        ),
                      );
                    },
            ),
            IconButton(
              icon: Icon(
                (showEvents && showLocations)
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: addingLocation || addingEvent
                  ? null
                  : () {
                      if (_isDoubleTapOnButton()) return;
                      _toggleVisibility();
                    },
            ),
            IconButton(
              icon: Icon(Icons.event),
              onPressed: addingLocation || addingEvent
                  ? null
                  : () {
                      if (_isDoubleTapOnButton()) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ListaEventos(),
                        ),
                      );
                    },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: addingLocation || addingEvent
                  ? null
                  : () {
                      if (currentUser != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VerPerfil(
                              userId: currentUser!.uid,
                              userEmail: currentUser!.email!,
                            ),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            if (addingLocation || addingEvent)
              Container(
                color: const Color.fromARGB(255, 63, 214, 63),
                padding: EdgeInsets.all(8.0),
                width: double.infinity, // Ocupa todo el ancho de la pantalla
                child: Text(
                  addingLocation
                      ? "Pulsa en el mapa donde quieres agregar una ubicación"
                      : "Pulsa en el mapa donde quieres agregar un evento",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Centra el texto
                ),
              ),
            Expanded(
              child: MapboxMap(
                accessToken:
                    "pk.eyJ1IjoiamF2aWVyY2Vyb2NhIiwiYSI6ImNsdnBhNG92YzBqd2Iya2sxeXYxeWUyYWkifQ.DSim5b1yxSAJjQioCrMDpQ",
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                    target: widget.initialPosition ?? defaultCenter,
                    zoom: widget.zoomLevel),
                onStyleLoadedCallback: _onStyleLoaded,
                onMapClick: _onMapClicked,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

