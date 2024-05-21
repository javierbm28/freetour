import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Seguidos extends StatelessWidget {
  final String userId;

  Seguidos({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidos'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.data() as Map<String, dynamic>;
          final seguidos = user['seguidos'] as List<dynamic>;

          return ListView.builder(
            itemCount: seguidos.length,
            itemBuilder: (context, index) {
              final seguidoId = seguidos[index] as String;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(seguidoId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text('Cargando...'),
                    );
                  }
                  final seguido = snapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(seguido['fotoPerfil']),
                    ),
                    title: Text(seguido['apodo']),
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
