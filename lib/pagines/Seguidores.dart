import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    leading: GestureDetector(
                      onTap: () => _navigateToProfile(context, seguidorId, seguidor['email']),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'lib/images/PerfilUser.png',
                          image: seguidor['fotoPerfil'],
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset('lib/images/PerfilUser.png', fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                    title: GestureDetector(
                      onTap: () => _navigateToProfile(context, seguidorId, seguidor['email']),
                      child: Text(
                        seguidor['apodo'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
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

