import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController controladorTextField1 = TextEditingController();
  TextEditingController controladorTextField2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discovery Tour"),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),

      body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Login", style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 63, 214, 63) ),),

            SizedBox(height: 50,),

            TextField(
              controller: controladorTextField1,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder()
              ),
            ),

            SizedBox(height: 50,),

            TextField(
              controller: controladorTextField2,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder()
              ),
            ),

            SizedBox(height: 100,),

            Text(
                  "Olvidaste la contraseña? Haz click aquí", 
                  style: TextStyle(color: Colors.blue),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 50),
                  ),
                  onPressed: () {}, 
                  child: Text("Registrate"),
                  ),

                  SizedBox(
                    width: 100,
                  ),
                  
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 50),
                  ),
                  onPressed: () {}, 
                  child: Text("Entrar"))
              ],
            )
          ],
        ),
      ),
    );
  }
}