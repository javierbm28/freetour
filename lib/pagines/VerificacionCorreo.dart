import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/Pagina_Login.dart';

class VerificacionCorreo extends StatefulWidget {
  final String email;
  final User user;

  const VerificacionCorreo({required this.email, required this.user});

  @override
  _VerificacionCorreoState createState() => _VerificacionCorreoState();
}

class _VerificacionCorreoState extends State<VerificacionCorreo> {
  bool _isSendingVerification = false;
  bool _isCheckingVerification = false;

  Future<void> _checkEmailVerified() async {
    setState(() {
      _isCheckingVerification = true;
    });

    await widget.user.reload();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {
      setState(() {
        _isCheckingVerification = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Correo no verificado aún"),
        ),
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isSendingVerification = true;
    });

    try {
      await widget.user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Correo de verificación enviado"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar el correo de verificación"),
        ),
      );
    } finally {
      setState(() {
        _isSendingVerification = false;
      });
    }
  }

  Future<void> _cancelRegistration() async {
    try {
      // Eliminar los datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).delete();
      
      // Eliminar la cuenta de usuario
      await widget.user.delete();

      // Navegar al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cancelar el registro: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevenir que se pueda volver hacia atrás
      child: Scaffold(
        appBar: AppBar(
          title: Text("Verificación de correo"),
          automaticallyImplyLeading: false, // Ocultar botón de volver atrás
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 400), // Limitar el ancho máximo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hemos enviado un enlace de verificación a tu correo electrónico.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (_isSendingVerification)
                  CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity, // Asegura que el botón use todo el ancho disponible
                    height: 50, // Altura del botón
                    child: ElevatedButton(
                      onPressed: _sendVerificationEmail,
                      child: Text(
                        "Reenviar correo de verificación",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 173, 172, 172), // Cambiar el color de fondo a blanco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Borde redondeado
                        ),
                        shadowColor: const Color.fromARGB(255, 105, 105, 105), // Añadir sombra
                        elevation: 5, // Añadir elevación para sombra
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50, // Altura del botón
                        child: ElevatedButton(
                          onPressed: _checkEmailVerified,
                          child: Text(
                            "Verificación",
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis, // Forzar el texto en una línea
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 63, 214, 63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.grey, // Añadir sombra
                            elevation: 5, // Añadir elevación para sombra
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 50, // Altura del botón
                        child: ElevatedButton(
                          onPressed: _cancelRegistration,
                          child: Text(
                            "Cancelar Registro",
                            style: TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis, // Forzar el texto en una línea
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.grey, // Añadir sombra
                            elevation: 5, // Añadir elevación para sombra
                          ),
                        ),
                      ),
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
}










