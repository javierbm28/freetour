import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/pagines/Pagina_Mapa.dart';

class PaginaInici extends StatefulWidget {
  const PaginaInici({super.key});

  @override
  State<PaginaInici> createState() => _PaginaIniciState();
}

class _PaginaIniciState extends State<PaginaInici> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 212, 152),
      appBar: AppBar(
        title: const Text("Discovery Tour"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
              "Hola, [nombre]",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Ganas de explorar y",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "conocer sitios nuevos?",
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
            BotoAuth(
              text: "Ir a mapa",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapaFreeTour()),
                );
              },
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
