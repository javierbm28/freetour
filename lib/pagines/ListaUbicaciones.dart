import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'FilterableMap.dart';

class ListaUbicaciones extends StatelessWidget {
  final String userEmail;

  ListaUbicaciones({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ubicaciones'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63), // Color del encabezado
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('userEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las ubicaciones'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No se encontraron ubicaciones'));
          }

          final locations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final data = locations[index].data() as Map<String, dynamic>;
              final coordinates = data['coordinates'] as GeoPoint;
              final category = data['category'] ?? 'Sin categoría';
              final subcategory = data['subcategory'] ?? 'Sin subcategoría';
              final name = data['name'] ?? 'Sin nombre';
              final imageUrl = data['imageUrl'] ?? '';

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
                        onPressed: () {
                          _showImageDialog(context, imageUrl);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.map),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilterableMap(
                                initialPosition: LatLng(coordinates.latitude, coordinates.longitude),
                                zoomLevel: 16.0,
                              ),
                            ),
                          );
                        },
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

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
              : Text('No hay imagen disponible'),
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
}



