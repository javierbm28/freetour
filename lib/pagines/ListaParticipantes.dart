import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VerPerfil.dart';

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
