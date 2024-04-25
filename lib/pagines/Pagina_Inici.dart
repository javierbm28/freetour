import 'package:flutter/material.dart';
import 'package:freetour/pagines/MapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaInici extends StatefulWidget {
  const PaginaInici({Key? key}) : super(key: key);

  @override
  State<PaginaInici> createState() => _PaginaIniciState();
}

class _PaginaIniciState extends State<PaginaInici> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout() async {
    await _auth.signOut();
    Navigator.pop(context); // Regresa a la pantalla anterior después de cerrar sesión
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final String userName = user != null ? user.displayName ?? 'Usuario' : 'Invitado';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 212, 152),
      appBar: AppBar(
        title: const Text("Discovery Tour"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error al obtener los datos');
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String nombre = data['nombre'] ?? '';
                final String apellidos = data['apellidos'] ?? '';
                return Text(
                  "Hola, $nombre $apellidos",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Ganas de explorar y conocer sitios nuevos?",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Image.asset('assets/foto.jfif'),
            ),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 63, 214, 63),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                minimumSize: const Size(500, 100),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50,
                ),
                fixedSize: const Size(150, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(),
                  ),
                );
              },
              child: const Text("Ir a mapa"),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

