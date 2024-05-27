import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VerPerfil.dart';

class ListaParticipantes extends StatelessWidget {
  final String eventId;

  ListaParticipantes({required this.eventId});

  Future<DocumentSnapshot> _getEventData() async {
    try {
      return await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    } catch (e) {
      print('Error al obtener los datos del evento: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: Colors.grey[300], // Fondo gris claro
      body: FutureBuilder<DocumentSnapshot>(
        future: _getEventData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No se encontraron datos para este evento.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final participants = data['participants'] as List<dynamic>;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return ListTile(
                leading: participant['profileImage'] != null
                    ? CircleAvatar(
                        backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: participant['profileImage'],
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset('lib/images/PerfilUser.png', fit: BoxFit.cover),
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      )
                    : Icon(Icons.person),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerPerfil(
                          userId: participant['uid'],
                          userEmail: participant['email'],
                        ),
                      ),
                    );
                  },
                  child: Text(participant['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



