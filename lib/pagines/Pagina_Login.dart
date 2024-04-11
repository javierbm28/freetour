import 'package:flutter/material.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Inici.dart';
import 'package:freetour/pagines/Pagina_Recuperacio.dart';
import 'package:freetour/pagines/Pagina_Registre.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar firebase_auth

class Login extends StatefulWidget {
  final void Function() alFerClic;

  const Login({
    Key? key,
    required this.alFerClic,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controladorEmail = TextEditingController();
  TextEditingController controladorContrasenya = TextEditingController();

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 63, 214, 63),
                ),
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
                      builder: (context) => const RecuperarContrasenya(),
                    ),
                  );
                },
                child: const Text(
                  "Olvidaste la contraseña? Haz click aquí",
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Registro(alFerClic: widget.alFerClic),
                        ),
                      );
                    },
                    child: const Text("Registrate"),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(150, 50),
                    ),
                    onPressed: () async {
                      try {
                        // Autenticar al usuario utilizando Firebase
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: controladorEmail.text,
                          password: controladorContrasenya.text,
                        );
                        // Navegar a la página de inicio después del inicio de sesión exitoso
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaginaInici(),
                          ),
                        );
                      } catch (e) {
                        print('Error al iniciar sesión: $e');
                        // Manejar el error de inicio de sesión
                      }
                    },
                    child: const Text("Entrar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
