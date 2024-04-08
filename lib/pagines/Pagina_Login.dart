import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Inici.dart';
import 'package:freetour/pagines/Pagina_Recuperacio.dart';
import 'package:freetour/pagines/Pagina_Registre.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controladorEmail = TextEditingController();
  TextEditingController controladorContrasenya = TextEditingController();

  void ferLogin(BuildContext buildContext) async {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaginaInici()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovery Tour"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      backgroundColor: const Color.fromARGB(98, 199, 202, 198),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Login",
                style: GoogleFonts.aBeeZee(
                  textStyle: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 63, 214, 63),
                  ),
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
                height: 50,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecuperarContrasenya()),
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
              const SizedBox(
                height: 50,
              ),
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BotoAuth(
                        text: "Registrarse",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Registro()),
                          );
                        }),
                    BotoAuth(
                      text: "Entrar",
                      onTap: () => ferLogin(context),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
