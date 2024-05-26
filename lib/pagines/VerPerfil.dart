import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'FilterableMap.dart';
import 'CategoriasFiltros.dart';
import 'MostrarDatos.dart';
import 'ListaUbicaciones.dart';
import 'ListaEventosUsuario.dart';
import 'DetalleEvento.dart';

class VerPerfil extends StatefulWidget {
  final String? userId;
  final String userEmail;

  VerPerfil({this.userId, required this.userEmail});

  @override
  _VerPerfilState createState() => _VerPerfilState();
}

class _VerPerfilState extends State<VerPerfil> {
  bool isFollowing = false;
  String? currentUserId;
  int followersCount = 0;
  int followingCount = 0;
  int eventsCount = 0;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _getUserData();
      await _checkIfFollowing();
      await _getFollowersCount();
      await _getFollowingCount();
      await _getEventsCount();
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<DocumentSnapshot?> _getUserData() async {
    try {
      if (widget.userId != null) {
        return FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.userEmail)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first;
        }
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<List<DocumentSnapshot>> _getUserLocations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('locations')
          .where('userEmail', isEqualTo: widget.userEmail)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting user locations: $e');
      return [];
    }
  }

  Future<void> _checkIfFollowing() async {
    if (currentUserId != null && widget.userId != null) {
      try {
        final followDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(widget.userId)
            .get();

        setState(() {
          isFollowing = followDoc.exists;
        });
      } catch (e) {
        print('Error checking if following: $e');
      }
    }
  }

  Future<void> _getFollowersCount() async {
    if (widget.userId != null) {
      try {
        final followersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('followers')
            .get();

        setState(() {
          followersCount = followersSnapshot.docs.length;
        });
      } catch (e) {
        print('Error getting followers count: $e');
      }
    }
  }

  Future<void> _getFollowingCount() async {
    if (widget.userId != null) {
      try {
        final followingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('following')
            .get();

        setState(() {
          followingCount = followingSnapshot.docs.length;
        });
      } catch (e) {
        print('Error getting following count: $e');
      }
    }
  }

  Future<void> _getEventsCount() async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('createdByEmail', isEqualTo: widget.userEmail)
          .get();

      setState(() {
        eventsCount = eventsSnapshot.docs.length;
      });
    } catch (e) {
      print('Error getting events count: $e');
    }
  }

  void _navigateToLocation(BuildContext context, LatLng coordinates, String category, String subcategory) {
    for (var catCategory in categories) {
      if (catCategory.name == category) {
        for (var subcatKey in catCategory.subcategories.keys) {
          catCategory.subcategories[subcatKey] = subcatKey == subcategory;
        }
      } else {
        for (var subcatKey in catCategory.subcategories.keys) {
          catCategory.subcategories[subcatKey] = false;
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilterableMap(
          initialPosition: coordinates,
          zoomLevel: 20.0,
        ),
      ),
    );
  }

  void _showProfileImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.white);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error);
            },
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _followUser() async {
    if (currentUserId != null && currentUserId != widget.userId) {
      try {
        final currentUserDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
        final followedUserDocRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);

        final isFollowing = (await currentUserDocRef.collection('following').doc(widget.userId).get()).exists;

        if (isFollowing) {
          await currentUserDocRef.collection('following').doc(widget.userId).delete();
          await followedUserDocRef.collection('followers').doc(currentUserId).delete();
        } else {
          final followedUserData = await followedUserDocRef.get();
          if (followedUserData.exists) {
            await currentUserDocRef.collection('following').doc(widget.userId).set({
              'userId': widget.userId,
              'userEmail': widget.userEmail,
              'userApodo': followedUserData['apodo'],
              'userProfileImage': followedUserData['fotoPerfil'],
            });

            final currentUserData = await currentUserDocRef.get();
            if (currentUserData.exists) {
              await followedUserDocRef.collection('followers').doc(currentUserId).set({
                'userId': currentUserId,
                'userEmail': currentUserData['email'],
                'userApodo': currentUserData['apodo'],
                'userProfileImage': currentUserData['fotoPerfil'],
              });
            }
          }
        }

        setState(() {
          this.isFollowing = !isFollowing;
        });

        _getFollowersCount();
        _getFollowingCount();
      } catch (e) {
        print('Error following user: $e');
      }
    }
  }

  void _navigateToFollowersOrFollowing(BuildContext context, bool isFollowers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowersOrFollowingList(
          userId: widget.userId,
          isFollowers: isFollowers,
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MostrarDatos()),
    );
  }

  void _navigateToLocationsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ListaUbicaciones(userEmail: widget.userEmail)),
    );
  }

  void _navigateToUserEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ListaEventosUsuario(userEmail: widget.userEmail)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Perfil del Usuario"),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para ver el perfil.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        actions: [
          if (currentUserId == widget.userId)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _navigateToEditProfile(context),
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos del usuario: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(child: Text('Usuario no encontrado'));
          }

          final userData = snapshot.data!;
          final nombre = userData['nombre'];
          final apellidos = userData['apellidos'];
          final apodo = userData['apodo'];
          final fotoPerfil = userData['fotoPerfil'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (fotoPerfil != null) {
                        _showProfileImageDialog(context, fotoPerfil);
                      }
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: fotoPerfil != null
                          ? NetworkImage(fotoPerfil)
                          : AssetImage('lib/images/PerfilUser.png') as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '$nombre $apellidos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Apodo: $apodo',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _getUserLocations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error al cargar las ubicaciones: ${snapshot.error}');
                      }
                      final locations = snapshot.data!;
                      final reviewsCount = locations.length;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToLocationsList(context),
                                child: Column(
                                  children: [
                                    Text('$reviewsCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('Ubicaciones', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _navigateToUserEvents(context),
                                child: Column(
                                  children: [
                                    Text('$eventsCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('Eventos', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _navigateToFollowersOrFollowing(context, true),
                                child: Column(
                                  children: [
                                    Text('$followersCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('Seguidores', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _navigateToFollowersOrFollowing(context, false),
                                child: Column(
                                  children: [
                                    Text('$followingCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('Seguidos', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (currentUserId != widget.userId)
                            SizedBox(height: 20),
                          if (currentUserId != widget.userId)
                            ElevatedButton(
                              onPressed: currentUserId != null ? _followUser : null,
                              child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                              ),
                            ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FollowersOrFollowingList extends StatelessWidget {
  final String? userId;
  final bool isFollowers;

  FollowersOrFollowingList({this.userId, required this.isFollowers});

  Future<List<DocumentSnapshot>> _getFollowersOrFollowing() async {
    final collection = isFollowers ? 'followers' : 'following';
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collection)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting followers or following: $e');
      return [];
    }
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
        title: Text(isFollowers ? 'Seguidores' : 'Seguidos'),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getFollowersOrFollowing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la lista: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay datos disponibles'));
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
              );
            },
          );
        },
      ),
    );
  }
}



























