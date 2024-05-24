import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'DetalleEvento.dart';

class EditableEventsList extends StatelessWidget {
  final String userEmail;

  EditableEventsList({required this.userEmail});

  Future<void> _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot event) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Seguro quieres borrar este evento?'),
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
                await event.reference.delete();
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
        title: Text('Mis Eventos'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('createdByEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;
          if (events.isEmpty) {
            return Center(child: Text('No hay eventos.'));
          }

          return ListView(
            children: events.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
              String formattedDate = DateFormat.yMd().format(dateTime);
              String formattedTime = DateFormat.jm().format(dateTime);

              return Card(
                color: Colors.grey[300], // Fondo gris claro para cada evento
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: $formattedDate'),
                      Text('Hora: $formattedTime'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(context, doc),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleEvento(eventId: doc.id),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
