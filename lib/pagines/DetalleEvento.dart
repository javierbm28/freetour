import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:freetour/pagines/ListaParticipantes.dart';
import 'package:freetour/pagines/FilterableMap.dart'; // Importa la página FilterableMap
import 'package:mapbox_gl/mapbox_gl.dart'; // Importa la librería de Mapbox
import 'package:flutter/services.dart' show rootBundle; // Importa la librería correcta
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Evento'),
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (data['imageUrl'] != null)
                  Image.network(
                    data['imageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 16.0),
                Text(data['title'], style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.0),
                Text(DateFormat.yMd().add_jm().format(dateTime), style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 8.0),
                Text('Creado por: ${data['createdBy']}', style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _toggleParticipation,
                  child: Text(isParticipating ? 'Desapuntarse' : 'Apuntarse'),
                ),
                SizedBox(height: 16.0),
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
                  child: Text('Mostrar ubicación'),
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

  // Widget _buildParticipantsList() {
  //   return Column(
  //     children: participants.map((participant) {
  //       return ListTile(
  //         leading: participant['profileImage'] != null && participant['profileImage'].isNotEmpty
  //             ? CircleAvatar(
  //                 backgroundImage: NetworkImage(participant['profileImage']),
  //               )
  //             : Icon(Icons.person),
  //         title: Text(participant['name']),
  //       );
  //     }).toList(),
  //   );
  // }
}











