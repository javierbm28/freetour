import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:freetour/pagines/FilterableMap.dart'; // Importa la página del mapa
import 'package:freetour/pagines/CategoriasFiltros.dart';

class VerPerfil extends StatelessWidget {
  final String? userId;
  final String userEmail;

  VerPerfil({this.userId, required this.userEmail});

  Future<DocumentSnapshot> _getUserData() async {
    if (userId != null) {
      return FirebaseFirestore.instance.collection('users').doc(userId).get();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);
    }
  }

  Future<List<DocumentSnapshot>> _getUserLocations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    return snapshot.docs;
  }

  void _navigateToLocation(BuildContext context, LatLng coordinates, String category, String subcategory) {
    // Activar filtros
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
              Navigator.of(context).pop(); // Cerrar el diálogo de pantalla completa
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos del usuario'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
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
                      radius: 80, // Incrementa el tamaño del avatar
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
                  Text(
                    'Ubicaciones de $apodo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _getUserLocations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error al cargar las ubicaciones');
                      }
                      final locations = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final name = location['name'] ?? 'Sin nombre';
                          final category = location['category'] ?? 'Sin categoría';
                          final subcategory = location['subcategory'] ?? 'Sin subcategoría';
                          final imageUrl = location['imageUrl'] ?? '';
                          final coordinates = location['coordinates'] as GeoPoint;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text('$category - $subcategory'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.image),
                                    onPressed: () => _showImageDialog(context, imageUrl),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.map),
                                    onPressed: () => _navigateToLocation(
                                      context,
                                      LatLng(coordinates.latitude, coordinates.longitude),
                                      category,
                                      subcategory,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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




