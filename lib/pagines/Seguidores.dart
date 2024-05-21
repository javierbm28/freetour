import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Seguidores extends StatelessWidget {
  final String userId;

  Seguidores({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.data() as Map<String, dynamic>;
          final seguidores = user['seguidores'] as List<dynamic>;

          return ListView.builder(
            itemCount: seguidores.length,
            itemBuilder: (context, index) {
              final seguidorId = seguidores[index] as String;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(seguidorId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text('Cargando...'),
                    );
                  }
                  final seguidor = snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(seguidor['fotoPerfil']),
                    ),
                    title: Text(seguidor['apodo']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
