import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<DocumentSnapshot> _getUserData() async {
    try {
      return await FirebaseFirestore.instance.collection('users').doc(userId).get();
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      throw e; // O maneja el error de manera adecuada
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Seguidores'),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para ver los seguidores.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: Colors.grey[300],
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No se encontraron datos para este usuario.'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;
          final seguidores = user['seguidores'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              itemCount: seguidores.length,
              itemBuilder: (context, index) {
                final seguidorId = seguidores[index] as String;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(seguidorId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Cargando...'),
                      );
                    }
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error al cargar los datos: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return ListTile(
                        title: Text('No se encontraron datos para este seguidor.'),
                      );
                    }
                    final seguidor = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      leading: GestureDetector(
                        onTap: () => _navigateToProfile(context, seguidorId, seguidor['email']),
                        child: CircleAvatar(
                          radius: 40,
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
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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





