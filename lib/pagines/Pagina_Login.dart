import 'package:flutter/material.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/auth/servei_auth.dart';
import 'package:freetour/pagines/Pagina_Inici.dart';
import 'package:freetour/pagines/Pagina_Recuperacio.dart';
import 'package:freetour/pagines/Pagina_Registre.dart';

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
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerContrasenya = TextEditingController();
  final ServeiAuth _serveiAuth = ServeiAuth();

  void _ferLogin(BuildContext context) async {
    try {
      await _serveiAuth.loginAmbEmailIPassword(
        _controllerEmail.text,
        _controllerContrasenya.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaginaInici(),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

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
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 63, 214, 63),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextFieldAuth(
                controller: _controllerEmail,
                obscureText: false,
                labelText: "Email",
              ),
              const SizedBox(
                height: 50,
              ),
              TextFieldAuth(
                controller: _controllerContrasenya,
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
                    onPressed: () => _ferLogin(context),
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
