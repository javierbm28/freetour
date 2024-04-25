import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarDades extends StatefulWidget {
  const EditarDades({Key? key});

  @override
  State<EditarDades> createState() => _EditarDadesState();
}

class _EditarDadesState extends State<EditarDades> {
  late User? _user;
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    obtenerDatosUsuario();
  }

  void obtenerDatosUsuario() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .get();
    final data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      _nombreController.text = data['nombre'] ?? '';
      _apellidosController.text = data['apellidos'] ?? '';
    });
  }

  void guardarCambios() {
    final nuevoNombre = _nombreController.text;
    final nuevosApellidos = _apellidosController.text;

    FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .update({'nombre': nuevoNombre, 'apellidos': nuevosApellidos})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar los cambios: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
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
                "Nombre: $nombre\nApellidos: $apellidos",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nombreController,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),

          TextField(
            controller: _apellidosController,
            decoration: InputDecoration(labelText: 'Apellidos'),
          ),

          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: guardarCambios,
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
} 