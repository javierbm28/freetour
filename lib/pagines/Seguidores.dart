import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VerPerfil.dart';

class Seguidores extends StatelessWidget {
  final String userId;

  Seguidores({required this.userId});

  void _navigateToProfile(BuildContext context, String userId, String userEmail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerPerfil(userId: userId, userEmail: userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: Colors.grey[300], // Fondo gris no muy oscuro
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.data() as Map<String, dynamic>;
          final seguidores = user['seguidores'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // Padding horizontal de 10
            child: ListView.builder(
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
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      leading: GestureDetector(
                        onTap: () => _navigateToProfile(context, seguidorId, seguidor['email']),
                        child: CircleAvatar(
                          radius: 40, // Tamaño de imagen más grande
                          backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: seguidor['fotoPerfil'],
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Image.asset('lib/images/PerfilUser.png', fit: BoxFit.cover),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () => _navigateToProfile(context, seguidorId, seguidor['email']),
                        child: Text(
                          seguidor['apodo'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Apodo más grande
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}




