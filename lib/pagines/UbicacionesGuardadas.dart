import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:freetour/pagines/FilterableMap.dart'; // Importa la página del mapa
import 'package:freetour/pagines/CategoriasFiltros.dart';

class UbicacionesGuardadas extends StatelessWidget {
  void _activateFilterAndNavigate(BuildContext context, String subcategory, LatLng coordinates) {
    for (var category in categories) {
      if (category.subcategories.containsKey(subcategory)) {
        category.subcategories[subcategory] = true;
        break;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilterableMap(
          initialPosition: coordinates,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicaciones de Interes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              return ExpansionTile(
                title: Text(category),
                children: subcategories.entries.map((entry) {
                  final subcategory = entry.key;
                  final subLocations = entry.value;
                  return ExpansionTile(
                    title: Text(subcategory),
                    children: subLocations.map((location) {
                      final imageUrl = location['imageUrl'] ?? '';
                      final coordinates = location['coordinates'];
                      return ListTile(
                        title: Text(location['name']),
                        subtitle: Text('Subcategoría: $subcategory'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showImageDialog(context, imageUrl);
                              },
                              child: Text('Imagen adjunta'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _activateFilterAndNavigate(
                                  context,
                                  subcategory,
                                  LatLng(coordinates.latitude, coordinates.longitude),
                                );
                              },
                              child: Text('Ver Ubicación'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            },
          );
        },
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
      final category = location['category'];
      final subcategory = location['subcategory'];

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




