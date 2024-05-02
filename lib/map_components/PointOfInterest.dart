/*class PointOfInterest {
  final String id;
  final String name;
  final String type; 
  final GeoPoint location;

  PointOfInterest({required this.id, required this.name, required this.type, required this.location});

  factory PointOfInterest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return PointOfInterest(
      id: doc.id,
      name: data['name'],
      type: data['type'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'location': location,
    };
  }
}*/
