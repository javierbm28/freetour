import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        builder: (context) =>
                            Login(alFerClic: widget.alFerClic),
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
                    BotoAuth(
                      text: "Registrarse",
                      onTap: () async {
                        try {
                          final UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: controladorEmail.text,
                            password: controladorContrasenya.text,
                          );

                          final User? user = userCredential.user;

                          if (user != null) {
                            await user.sendEmailVerification();
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Verifica tu correo electrónico"),
                                content: Text(
                                    "Hemos enviado un enlace de verificación a tu correo. Verifica tu correo antes de continuar."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("Ok"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            throw Exception(
                                "No se pudo crear la cuenta del usuario.");
                          }
                        } catch (e) {
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
                      },
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
