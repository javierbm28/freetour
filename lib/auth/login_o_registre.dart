import 'package:flutter/material.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:freetour/pagines/Pagina_Registre.dart';


class LoginORegistre extends StatefulWidget {
  const LoginORegistre({super.key});

  @override
  State<LoginORegistre> createState() => _LoginORegistreState();
}

class _LoginORegistreState extends State<LoginORegistre> {

  bool mostraPaginaLogin = true;

  void intercanviarPaginesLoginRegistre() {
    setState(() {
      mostraPaginaLogin = !mostraPaginaLogin;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (mostraPaginaLogin) {
      return Login(alFerClic: intercanviarPaginesLoginRegistre,);
    } else {
      return Registro(alFerClic: intercanviarPaginesLoginRegistre,);
    }
    
  }
}