import 'package:flutter/material.dart';
import 'package:freetour/components/boto_auth.dart';
import 'package:freetour/components/textField_auth.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:google_fonts/google_fonts.dart';

class RecuperarContrasenya extends StatefulWidget {
  const RecuperarContrasenya({super.key});

  @override
  State<RecuperarContrasenya> createState() => _RecuperarContrasenyaState();
}

class _RecuperarContrasenyaState extends State<RecuperarContrasenya> {

  TextEditingController controladorEmail = TextEditingController();
  TextEditingController controladorContrasenya = TextEditingController();

  bool boton = true;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              Text("Restablecer", 
                style: GoogleFonts.aBeeZee
                (textStyle: const TextStyle(
                  fontSize: 50, 
                  fontWeight: FontWeight.bold, 
                  color: Color.fromARGB(255, 63, 214, 63),
                  ),
                ),
              ),
              Text("contraseña", 
                style: GoogleFonts.aBeeZee
                (textStyle: const TextStyle(
                  fontSize: 50, 
                  fontWeight: FontWeight.bold, 
                  color: Color.fromARGB(255, 63, 214, 63),
                  ),
                ),
              ),
        
              const SizedBox(height: 50,),
        
              TextFieldAuth(
                controller: controladorEmail, 
                obscureText: false, 
                labelText: "Email",
              ),
        
              const SizedBox(height: 50,),
        
              TextFieldAuth(
                controller: controladorContrasenya, 
                obscureText: true, 
                labelText: "Nueva Contraseña",
              ),
        
              const SizedBox(height: 100,),
        
              const Icon(
                Icons.recommend,
                size: 80,
              ),
        
              const Text(
                "Recuerda apuntarte la nueva contraseña ;)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
        
              const SizedBox(height: 100,),
        
              BotoAuth(
                text: "Recuperar contraseña", 
                onTap: () {
                  Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}