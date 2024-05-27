import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('followers')
            .snapshots()
            .map((snapshot) => snapshot.docs),
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
              final followerUserId = user['userId'];
              final userEmail = user['userEmail'];
              final userApodo = user['userApodo'];
              final userProfileImage = user['userProfileImage'];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                leading: GestureDetector(
                  onTap: () => _navigateToProfile(context, followerUserId, userEmail),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('lib/images/PerfilUser.png'),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userProfileImage,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset('lib/images/PerfilUser.png', fit: BoxFit.cover),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
                title: GestureDetector(
                  onTap: () => _navigateToProfile(context, followerUserId, userEmail),
                  child: Text(
                    userApodo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () async {
                    await _removeFollower(followerUserId);
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




