import 'package:flutter/material.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar cloud_firestore

class Registro extends StatefulWidget {
  final void Function() alFerClic;

  const Registro({
    Key? key,
    required this.alFerClic,
  }) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controladorEmail = TextEditingController();
  TextEditingController controladorContrasenya = TextEditingController();
  TextEditingController controladorNombre = TextEditingController();
  TextEditingController controladorApellidos = TextEditingController();
  bool _formFilled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovery Tour"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: const Color.fromARGB(99, 141, 145, 140),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Registro",
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 63, 214, 63),
                    ),
                  ),
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                TextFieldAuth(
                  controller: controladorNombre,
                  obscureText: false,
                  labelText: "Nombre",
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                TextFieldAuth(
                  controller: controladorApellidos,
                  obscureText: false,
                  labelText: "Apellidos",
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                TextFieldAuth(
                  controller: controladorEmail,
                  obscureText: false,
                  labelText: "Email",
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                TextFieldAuth(
                  controller: controladorContrasenya,
                  obscureText: true,
                  labelText: "Contraseña",
                ),
            
                const SizedBox(
                  height: 100,
                ),
            
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(alFerClic: widget.alFerClic),
                      ),
                    );
                  },
                  child: const Text(
                    "Ya tienes cuenta? Haz click aquí para iniciar sesión",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 50),
                      ),
                      onPressed: () async {
                        try {
                          // Registrar al usuario utilizando Firebase
                          final UserCredential userCredential =
                              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: controladorEmail.text,
                            password: controladorContrasenya.text,
                          );

                          // Obtener el ID del usuario registrado
                          final String userId = userCredential.user!.uid;

                          // Guardar el nombre y el apellido en Firestore Database
                          await FirebaseFirestore.instance.collection('users').doc(userId).set({
                            'nombre': controladorNombre.text,
                            'apellidos': controladorApellidos.text,
                          });

                          // Navegar a la página de inicio después del registro exitoso
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(alFerClic: widget.alFerClic),
                            ),
                          );
                        } catch (e) {
                          print('Error al registrar usuario: $e');
                          // Manejar el error de registro de usuario
                        }
                      },
                      child: const Text("Crear cuenta"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
