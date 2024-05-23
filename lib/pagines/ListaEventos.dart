import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:freetour/pagines/DetalleEvento.dart';

class ListaEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Eventos'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              DateTime dateTime = (data['dateTime'] as Timestamp).toDate();

              return ListTile(
                title: Text(data['title']),
                subtitle: Text(DateFormat.yMd().add_jm().format(dateTime)),
                trailing: Text(data['createdBy'] ?? 'Desconocido'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleEvento(eventId: doc.id),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}


