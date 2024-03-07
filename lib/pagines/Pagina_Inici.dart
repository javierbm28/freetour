import 'package:flutter/material.dart';

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

            const Text("Hola, [nombre]",
              style: TextStyle(
                fontSize: 50, 
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 50,
            ),

            const Text("Ganas de explorar y conocer sitios nuevos?",
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
                  onPressed: () {},
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
