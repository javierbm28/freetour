import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar firebase_auth

class RecuperarContrasenya extends StatefulWidget {
  const RecuperarContrasenya({Key? key});

  @override
  State<RecuperarContrasenya> createState() => _RecuperarContrasenyaState();
}

class _RecuperarContrasenyaState extends State<RecuperarContrasenya> {
  TextEditingController controladorEmail = TextEditingController();

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Recuperar Contraseña",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 63, 214, 63),
                ),
              ),
              const SizedBox(height: 50,),
              TextFieldAuth(
                controller: controladorEmail,
                obscureText: false,
                labelText: "Email",
              ),
              const SizedBox(height: 50,),

              const Icon(Icons.recommend),
              Text("Recuerda apuntarte la nueva contraseña ;)"),

              const SizedBox(height: 30,),

              BotoAuth(
                text: "Recuperar contraseña", 
                onTap: () async {
                  try {
                    // Enviar correo para restablecer la contraseña
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: controladorEmail.text,
                    );
                    // Mostrar mensaje de éxito
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Éxito"),
                          content: const Text("Se ha enviado un correo para restablecer la contraseña."),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Mostrar mensaje de error
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: Text("Error al enviar el correo"),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

