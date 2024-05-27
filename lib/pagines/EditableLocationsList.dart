import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'FilterableMap.dart';
import 'CategoriasFiltros.dart';

class EditableLocationsList extends StatelessWidget {
  final String userEmail;

  EditableLocationsList({required this.userEmail});

  Future<void> _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot location) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Seguro quieres borrar esta ubicación?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Borrar'),
              onPressed: () async {
                await location.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Future<List<DocumentSnapshot>> _getUserLocations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Ubicaciones'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getUserLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las ubicaciones'));
          }
          final locations = snapshot.data ?? [];
          if (locations.isEmpty) {
            return Center(child: Text('No hay ubicaciones.'));
          }
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final name = location['name'] ?? 'Sin nombre';
              final category = location['category'] ?? 'Sin categoría';
              final subcategory = location['subcategory'] ?? 'Sin subcategoría';
              final imageUrl = location['imageUrl'] ?? '';
              final coordinates = location['coordinates'] as GeoPoint;

              return Card(
                color: Colors.grey[300], // Fondo gris claro para cada ubicación
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
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmationDialog(context, location),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
