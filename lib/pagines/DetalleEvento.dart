import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:freetour/pagines/ListaParticipantes.dart';
import 'package:freetour/pagines/FilterableMap.dart'; // Importa la página FilterableMap
import 'package:mapbox_gl/mapbox_gl.dart'; // Importa la librería de Mapbox
import 'package:flutter/services.dart' show rootBundle; // Importa la librería correcta
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freetour/pagines/VerPerfil.dart'; // Importa la página VerPerfil

class DetalleEvento extends StatefulWidget {
  final String eventId;

  DetalleEvento({required this.eventId});

  @override
  _DetalleEventoState createState() => _DetalleEventoState();
}

class _DetalleEventoState extends State<DetalleEvento> {
  bool isParticipating = false;
  int participantCount = 0;
  List<Map<String, dynamic>> participants = [];
  bool isDescriptionExpanded = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('participants')) {
      List<dynamic> participantsList = data['participants'];
      List<Map<String, dynamic>> loadedParticipants = [];

      for (var participant in participantsList) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(participant['uid']).get();
        final userData = userDoc.data() as Map<String, dynamic>;
        loadedParticipants.add({
          'uid': participant['uid'],
          'name': userData['name'] ?? 'Nombre no disponible',
          'profileImage': userData['profileImage'] ?? '',
          'email': userData['email'] ?? 'Correo no disponible',
        });
      }

      setState(() {
        participantCount = loadedParticipants.length;
        participants = loadedParticipants;
        isParticipating = participantsList.any((p) => p['uid'] == currentUser?.uid);
      });
    } else {
      setState(() {
        participantCount = 0;
        participants = [];
        isParticipating = false;
      });
    }
  }

  Future<void> _toggleParticipation() async {
    if (currentUser == null) return;

    DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
    DocumentSnapshot eventDoc = await eventRef.get();
    final data = eventDoc.data() as Map<String, dynamic>?;

    if (data == null) return;

    List<dynamic> participantsList = data.containsKey('participants') ? data['participants'] : [];

    if (isParticipating) {
      participantsList.removeWhere((p) => p['uid'] == currentUser!.uid);
    } else {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      participantsList.add({
        'uid': currentUser!.uid,
        'name': userData['apodo'] ?? 'Nombre no disponible',
        'profileImage': userData['fotoPerfil'] ?? '',
        'email': currentUser!.email ?? 'Correo no disponible',
      });
    }

    await eventRef.update({'participants': participantsList});
    _loadParticipants();
  }

  void _navigateToCreatorProfile(String userEmail) async {
    // Fetch the creator's user document using their email
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      final userId = userDoc.id;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerPerfil(userId: userId, userEmail: userEmail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Evento'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(widget.eventId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
          GeoPoint geoPoint = data['coordinates'];

          return SingleChildScrollView(
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (data['imageUrl'] != null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Image.network(
                          data['imageUrl'],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 16.0),
                    Text(data['title'], style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text(DateFormat.yMd().add_jm().format(dateTime), style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _navigateToCreatorProfile(data['createdByEmail']),
                      child: Text(
                        'Creado por: ${data['createdBy']}',
                        style: TextStyle(fontSize: 16.0, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleParticipation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            shadowColor: Colors.grey,
                          ),
                          child: Text(isParticipating ? 'Desapuntarse' : 'Apuntarse'),
                        ),
                        SizedBox(width: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilterableMap(
                                  initialPosition: LatLng(geoPoint.latitude, geoPoint.longitude),
                                  zoomLevel: 16.0, // Ajusta el nivel de zoom según sea necesario
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            shadowColor: Colors.grey,
                          ),
                          child: Text('Mostrar ubicación'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text('Descripción', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    _buildDescription(data['description']),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListaParticipantes(eventId: widget.eventId),
                          ),
                        );
                      },
                      child: Text(
                        'Participan: $participantCount personas',
                        style: TextStyle(fontSize: 16.0, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // _buildParticipantsList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescription(String description) {
    final maxLines = 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(fontSize: 19.0),
          maxLines: isDescriptionExpanded ? null : maxLines,
          overflow: isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (description.length > 100) // You can adjust the length threshold as needed
          TextButton(
            onPressed: () {
              setState(() {
                isDescriptionExpanded = !isDescriptionExpanded;   
              });
            },
            child: Text(isDescriptionExpanded ? 'Leer menos' : 'Leer más'),
          ),
      ],
    );
  }
}












