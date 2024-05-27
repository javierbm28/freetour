import 'package:flutter/material.dart';

class BotoAuth extends StatelessWidget {
  final String text;
  Function()? onTap;

  BotoAuth({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 130, 243, 78),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10, 
          vertical: 10,
        ),
        margin: const EdgeInsets.all(25),
        child: Text(
          text,
          style: TextStyle(
            color: const Color.fromARGB(255, 62, 182, 66),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}