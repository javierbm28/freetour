import 'package:flutter/material.dart';

class TextFieldAuth extends StatelessWidget {

  final TextEditingController controller;
  final bool obscureText;
  final String labelText;

  const TextFieldAuth({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25,),
      child: TextField(
        cursorColor: const Color.fromARGB(255, 26, 222, 0),
        style: const TextStyle(
          color: Color.fromARGB(255, 5, 154, 0),
        ),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          
        ),
      ),
    );
  }
}