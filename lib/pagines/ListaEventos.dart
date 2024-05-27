import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freetour/pagines/DetalleEvento.dart';
import 'package:freetour/pagines/Pagina_Login.dart';

class ListaEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Lista de Eventos'),
          backgroundColor: Color.fromARGB(255, 63, 214, 63),
        ),
        body: Center(
          child: Text('Por favor, inicie sesión para ver los eventos.'),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Lista de Eventos'),
          backgroundColor: Color.fromARGB(255, 63, 214, 63),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('dateTime', isGreaterThan: Timestamp.now())
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
                String formattedDate = DateFormat.yMd().format(dateTime);
                String formattedTime = DateFormat.jm().format(dateTime);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      data['title'],
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: $formattedDate'),
                        Text('Hora: $formattedTime'),
                      ],
                    ),
                    trailing: Text(
                      data['createdBy'] ?? 'Desconocido',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
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
        ));
  }
}
