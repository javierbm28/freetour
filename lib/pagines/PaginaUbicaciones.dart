import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ubicaciones extends StatefulWidget {
  const Ubicaciones({super.key});

  @override
  State<Ubicaciones> createState() => _UbicacionesState();
}

class _UbicacionesState extends State<Ubicaciones> {
  late User? _user;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /*FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(_user?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Text('Error al obtener los datos');
              }
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final String nombre = data['nombre'] ?? '';
              final String apellidos = data['apellidos'] ?? '';
              return Text(
                "Nombre: $nombre\nApellidos: $apellidos\n",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),*/
        ],
      ),
    );
  }
}
