import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:freetour/pagines/FilterableMap.dart'; // Importa la página del mapa
import 'package:freetour/pagines/CategoriasFiltros.dart';
import 'package:freetour/pagines/VerPerfil.dart'; // Importa la página de VerPerfil

class UbicacionesGuardadas extends StatelessWidget {
  void _activateFilterAndNavigate(BuildContext context, String category, String subcategory, LatLng coordinates) {
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

  void _navigateToUserProfile(BuildContext context, String userEmail) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      String userId = userDoc.id;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerPerfil(userId: userId, userEmail: userEmail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicaciones de Interes'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63), // Fondo del AppBar
      ),
      body: Container(
        color: Colors.white, // Fondo blanco para toda la página
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('locations').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final locations = snapshot.data?.docs ?? [];
            final groupedLocations = _groupLocationsByCategory(locations);

            return ListView.builder(
              itemCount: groupedLocations.keys.length,
              itemBuilder: (context, index) {
                final category = groupedLocations.keys.elementAt(index);
                final subcategories = groupedLocations[category]!;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Margen alrededor de cada categoría
                  decoration: BoxDecoration(
                    color: Colors.grey, // Fondo gris para las categorías
                    border: Border.all(color: Colors.black, width: 2), // Borde negro
                    borderRadius: BorderRadius.circular(10), // Borde redondeado
                  ),
                  child: ExpansionTile(
                    backgroundColor: Colors.grey, // Fondo gris para las categorías
                    title: Text(
                      category,
                      style: TextStyle(color: Colors.white), // Texto en blanco para mejor contraste
                    ),
                    initiallyExpanded: false, // Empezar cerrados
                    children: subcategories.entries.map((entry) {
                      final subcategory = entry.key;
                      final subLocations = entry.value;
                      return ExpansionTile(
                        backgroundColor: Colors.grey[300], // Fondo gris claro para las subcategorías
                        title: Text(
                          subcategory,
                          style: TextStyle(color: Colors.black), // Texto negro para las subcategorías
                        ),
                        initiallyExpanded: false, // Empezar cerrados
                        children: subLocations.map((location) {
                          final imageUrl = location['imageUrl'] ?? '';
                          final coordinates = location['coordinates'];
                          final apodo = location['userApodo'] ?? 'Sin apodo';
                          final userEmail = location['userEmail'];

                          return ListTile(
                            title: Text(location['name'] ?? 'Sin nombre'),
                            subtitle: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _navigateToUserProfile(context, userEmail),
                                  child: Text(
                                    apodo,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showImageDialog(context, imageUrl);
                                  },
                                  child: Text('Imagen adjunta'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // Fondo blanco para el botón
                                    foregroundColor: Colors.black, // Texto negro
                                    side: BorderSide(color: Colors.black), // Borde negro
                                    shadowColor: Colors.grey, // Sombra
                                    elevation: 5, // Añadir elevación para sombra
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // Borde redondeado
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    _activateFilterAndNavigate(
                                      context,
                                      category,
                                      subcategory,
                                      LatLng(coordinates.latitude, coordinates.longitude),
                                    );
                                  },
                                  child: Text('Ver Ubicación'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // Fondo blanco para el botón
                                    foregroundColor: Colors.black, // Texto negro
                                    side: BorderSide(color: Colors.black), // Borde negro
                                    shadowColor: Colors.grey, // Sombra
                                    elevation: 5, // Añadir elevación para sombra
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // Borde redondeado
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
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

  Map<String, Map<String, List<DocumentSnapshot>>> _groupLocationsByCategory(List<DocumentSnapshot> locations) {
    final Map<String, Map<String, List<DocumentSnapshot>>> groupedLocations = {};

    for (var location in locations) {
      final category = location['category'] ?? 'Sin categoría';
      final subcategory = location['subcategory'] ?? 'Sin subcategoría';

      if (!groupedLocations.containsKey(category)) {
        groupedLocations[category] = {};
      }
      if (!groupedLocations[category]!.containsKey(subcategory)) {
        groupedLocations[category]![subcategory] = [];
      }
      groupedLocations[category]![subcategory]!.add(location);
    }

    return groupedLocations;
  }
}










