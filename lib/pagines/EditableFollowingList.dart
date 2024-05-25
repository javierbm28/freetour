import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VerPerfil.dart';

class EditableFollowingList extends StatelessWidget {
  final String userId;

  EditableFollowingList({required this.userId});

  Future<List<DocumentSnapshot>> _getFollowing() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();
    return snapshot.docs;
  }

  Future<void> _unfollowUser(String followingId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(followingId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(followingId)
        .collection('followers')
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
        title: Text('Seguidos'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getFollowing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la lista'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay seguidos disponibles'));
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
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                leading: GestureDetector(
                  onTap: () => _navigateToProfile(context, userId, userEmail),
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
                  onTap: () => _navigateToProfile(context, userId, userEmail),
                  child: Text(
                    userApodo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () async {
                    await _unfollowUser(userId);
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



