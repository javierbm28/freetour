import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/MostrarDatos.dart';
import 'package:freetour/pagines/Seguidores.dart';
import 'package:freetour/pagines/Seguidos.dart';

class PerfilUsuario extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  PerfilUsuario({required this.userId, this.isCurrentUser = false});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Usuario'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.data() as Map<String, dynamic>;
          final apodo = user['apodo'];
          final fotoPerfil = user['fotoPerfil'];
          final email = user['email'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(fotoPerfil),
                ),
                SizedBox(height: 16),
                Text(
                  apodo,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                if (isCurrentUser)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MostrarDatos(),
                        ),
                      );
                    },
                    child: Text('Editar datos'),
                  ),
                if (!isCurrentUser)
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para seguir al usuario
                    },
                    child: Text('Seguir'),
                  ),
                SizedBox(height: 16),
                Text('Ubicaciones agregadas', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('locations')
                        .where('userEmail', isEqualTo: email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final locations = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(location['name']),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Seguidores(userId: userId),
                          ),
                        );
                      },
                      child: Text('Seguidores'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Seguidos(userId: userId),
                          ),
                        );
                      },
                      child: Text('Seguidos'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
