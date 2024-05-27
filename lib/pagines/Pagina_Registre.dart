import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:freetour/pagines/VerificacionCorreo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class Registro extends StatefulWidget {
  final void Function()? alFerClic;

  const Registro({
    Key? key,
    this.alFerClic,
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
  TextEditingController controladorApodo = TextEditingController();
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovery"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Registro",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 63, 214, 63),
                  ),
                ),
                const SizedBox(height: 50),
                TextFieldAuth(
                  controller: controladorNombre,
                  obscureText: false,
                  labelText: "Nombre",
                ),
                const SizedBox(height: 20),
                TextFieldAuth(
                  controller: controladorApellidos,
                  obscureText: false,
                  labelText: "Apellidos",
                ),
                const SizedBox(height: 20),
                TextFieldAuth(
                  controller: controladorEmail,
                  obscureText: false,
                  labelText: "Email",
                ),
                const SizedBox(height: 20),
                TextFieldAuth(
                  controller: controladorContrasenya,
                  obscureText: true,
                  labelText: "Contraseña",
                ),
                const SizedBox(height: 20),
                TextFieldAuth(
                  controller: controladorApodo,
                  obscureText: false,
                  labelText: "Apodo",
                ),
                const SizedBox(height: 100),
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
                    const SizedBox(height: 200),
                    BotoAuth(
                      text: _isRegistering ? "Registrando..." : "Registrarse",
                      onTap: _isRegistering ? null : _registrarUsuario,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: controladorEmail.text,
          password: controladorContrasenya.text,
        );

        final User? user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();
          final imageUrl = await _uploadDefaultProfileImage(user.uid);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nombre': controladorNombre.text,
            'apellidos': controladorApellidos.text,
            'email': controladorEmail.text,
            'apodo': controladorApodo.text,
            'fotoPerfil': imageUrl,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificacionCorreo(
                email: controladorEmail.text,
                user: user,
              ),
            ),
          );
        } else {
          throw Exception("No se pudo crear la cuenta del usuario.");
        }
      } catch (e) {
        setState(() {
          _isRegistering = false;
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Error en el registro"),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("Cerrar"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String> _uploadDefaultProfileImage(String userId) async {
    final ByteData bytes = await rootBundle.load('lib/images/PerfilUser.png');
    final Uint8List list = bytes.buffer.asUint8List();

    final Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$userId.png');
    final UploadTask uploadTask = storageRef.putData(list);
    final TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }
}


