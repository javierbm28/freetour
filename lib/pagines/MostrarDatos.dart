import 'package:flutter/material.dart';
import 'package:freetour/pagines/Pagina_editar_dades.dart';

class Datos extends StatelessWidget {
  const Datos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Editar datos"),
          backgroundColor: const Color.fromARGB(255, 63, 214, 63),
        ),
        body: const EditarDades(),
      ),
    );
  }
}
