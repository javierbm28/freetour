import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UbicacionesGuardadas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicaciones Guardadas'),
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
                      return ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text(location['name']),
                        subtitle: Text('Subcategoría: $subcategory'),
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

