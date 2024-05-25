import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/pagines/MostrarDatos.dart'; // Asegúrate de que esta es la clase correcta
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:freetour/pagines/FilterableMap.dart';
import 'verPerfil.dart';

class PaginaInici extends StatefulWidget {
  const PaginaInici({Key? key}) : super(key: key);

  @override
  State<PaginaInici> createState() => _PaginaIniciState();
}

class _PaginaIniciState extends State<PaginaInici> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _navigateToProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerPerfil(userId: user.uid, userEmail: user.email!),
        ),
      );
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MostrarDatos()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('');
              }
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Text('');
              }
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final String nombre = data['nombre'] ?? '';
              final String apellidos = data['apellidos'] ?? '';
              return Text('$nombre $apellidos');
            },
          ),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
          actions: [
            IconButton(
              onPressed: _navigateToProfile,
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: user == null
            ? Center(child: Text('No hay usuario autenticado'))
            : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "lib/images/Discovery.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FilterableMap()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                            backgroundColor: Color.fromARGB(255, 63, 214, 63),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black, width: 2),
                            ),
                            elevation: 5,
                            shadowColor: Colors.grey,
                          ),
                          child: Text(
                            "Ir a mapa",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

