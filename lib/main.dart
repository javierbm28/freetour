import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freetour/auth/portal_auth.dart';
import 'package:freetour/firebase_options.dart';
import 'package:freetour/pagines/Pagina_Login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PortalAuth(),
    );
  }
}
