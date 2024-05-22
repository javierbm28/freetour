import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/pagines/MostrarDatos.dart'; // Asegúrate de que esta es la clase correcta
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:freetour/pagines/FilterableMap.dart';
import 'package:video_player/video_player.dart';
import 'verPerfil.dart';

class PaginaInici extends StatefulWidget {
  const PaginaInici({Key? key}) : super(key: key);

  @override
  State<PaginaInici> createState() => _PaginaIniciState();
}

class _PaginaIniciState extends State<PaginaInici> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("lib/images/video_fondo.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          title: const Text("Discovery"),
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
                  if (_controller.value.isInitialized)
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
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
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 45, 255, 3),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Bienvenido/a",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 45, 255, 3),
                            ),
                          ),
                          const SizedBox(height: 245),
                          BotoAuth(
                            text: "Ir a mapa",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FilterableMap()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
