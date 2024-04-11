
import 'package:flutter/material.dart';

class ItemUsuari extends StatelessWidget {

  final String emailUsuari;
  final void Function()? onTap;

  const ItemUsuari({
    super.key,
    required this.emailUsuari,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 10,),
            Text(emailUsuari),
          ],
        ),
      ),
    );
  }
}