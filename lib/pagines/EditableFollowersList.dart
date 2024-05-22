import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VerPerfil.dart';

class EditableFollowersList extends StatelessWidget {
  final String userId;

  EditableFollowersList({required this.userId});

  Future<List<DocumentSnapshot>> _getFollowers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();
    return snapshot.docs;
  }

  Future<void> _removeFollower(String followerId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .doc(followerId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(followerId)
        .collection('following')
        .doc(userId)
        .delete();
  }

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
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getFollowers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la lista'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay seguidores disponibles'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user['userId'];
              final userEmail = user['userEmail'];
              final userApodo = user['userApodo'];
              final userProfileImage = user['userProfileImage'];

              return ListTile(
                leading: GestureDetector(
                  onTap: () => _navigateToProfile(context, userId, userEmail),
                  child: CircleAvatar(
                    backgroundImage: userProfileImage != null ? NetworkImage(userProfileImage) : null,
                  ),
                ),
                title: GestureDetector(
                  onTap: () => _navigateToProfile(context, userId, userEmail),
                  child: Text(userApodo),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () async {
                    await _removeFollower(userId);
                    // Update the list after removal
                    (context as Element).markNeedsBuild();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

