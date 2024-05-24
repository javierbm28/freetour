import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    leading: GestureDetector(
                      onTap: () => _navigateToProfile(context, seguidoId, seguido['email']),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'lib/images/PerfilUser.png',
                          image: seguido['fotoPerfil'],
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset('lib/images/PerfilUser.png', fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                    title: GestureDetector(
                      onTap: () => _navigateToProfile(context, seguidoId, seguido['email']),
                      child: Text(
                        seguido['apodo'],
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
