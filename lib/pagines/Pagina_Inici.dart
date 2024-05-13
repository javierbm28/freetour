
import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/pagines/MostrarDatos.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:freetour/pagines/FilterableMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/Pagina_editar_dades.dart';
import 'package:freetour/pagines/Pagina_Login.dart';

class PaginaInici extends StatefulWidget {
  const PaginaInici({
    Key? key,
  }) : super(key: key);

  @override
  State<PaginaInici> createState() => _PaginaIniciState();
}

class _PaginaIniciState extends State<PaginaInici> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout() async {
    await _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    ); // Regresa a la pantalla anterior después de cerrar sesión
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final String userName =
        user != null ? user.displayName ?? 'Usuario' : 'Invitado';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovery"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Datos(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/foto_fondo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 100,),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .get(),
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
                    return Center(
                      child: Text(
                        "$nombre $apellidos",
                        style: const TextStyle(
                          fontSize: 90,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Bienvenido/a",
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 416,
                ),
                BotoAuth(
                  text: "Ir a mapa",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                    builder: (context) => FilterableMap(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
