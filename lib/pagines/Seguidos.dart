import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VerPerfil.dart';

class Seguidos extends StatelessWidget {
  final String userId;

  Seguidos({required this.userId});

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidos'),
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
          final seguidos = user['seguidos'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              itemCount: seguidos.length,
              itemBuilder: (context, index) {
                final seguidoId = seguidos[index] as String;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(seguidoId).get(),
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
                        title: Text('No se encontraron datos para este seguido.'),
                      );
                    }
                    final seguido = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      leading: GestureDetector(
                        onTap: () => _navigateToProfile(context, seguidoId, seguido['email']),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: seguido['fotoPerfil'],
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
                        onTap: () => _navigateToProfile(context, seguidoId, seguido['email']),
                        child: Text(
                          seguido['apodo'],
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


