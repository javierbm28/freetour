import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/verPerfil.dart';

class ListaParticipantes extends StatelessWidget {
  final String eventId;

  ListaParticipantes({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
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
                        backgroundImage: NetworkImage(participant['profileImage']),
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
