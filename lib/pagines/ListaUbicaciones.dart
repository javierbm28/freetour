import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:freetour/pagines/FilterableMap.dart';

class ListaUbicaciones extends StatelessWidget {
  final String userEmail;

  ListaUbicaciones({required this.userEmail});

  void _navigateToLocation(BuildContext context, LatLng coordinates, String category, String subcategory) {
    // Implementar la lógica para navegar a la ubicación con los filtros aplicados
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
        title: Text('Lista de Ubicaciones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              GeoPoint geoPoint = data['coordinates'];
              String name = data['name'] ?? 'Sin nombre';
              String category = data['category'] ?? 'Sin categoría';
              String subcategory = data['subcategory'] ?? 'Sin subcategoría';
              String imageUrl = data['imageUrl'] ?? '';

              return ListTile(
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
                        LatLng(geoPoint.latitude, geoPoint.longitude),
                        category,
                        subcategory,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
