import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data'; // Importa este paquete para Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;

class MostrarDatos extends StatefulWidget {
  @override
  _MostrarDatosState createState() => _MostrarDatosState();
}

class _MostrarDatosState extends State<MostrarDatos> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidosController = TextEditingController();
  TextEditingController _apodoController = TextEditingController();
  String? _profileImageUrl;
  File? _imageFile;
  Uint8List? _imageBytes; // Para web
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = snapshot.data()!;
    _nombreController.text = data['nombre'];
    _apellidosController.text = data['apellidos'];
    _apodoController.text = data['apodo'];
    setState(() {
      _profileImageUrl = data['fotoPerfil'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _imageBytes = await pickedFile.readAsBytes();
        _imageFile = null;
      } else {
        _imageFile = File(pickedFile.path);
        _imageBytes = null;
      }
      setState(() {}); // Update the state after picking the image
    }
  }

  Future<void> _saveChanges() async {
    String? imageUrl;
    if (_imageFile != null || _imageBytes != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
      if (kIsWeb) {
        await storageRef.putData(_imageBytes!);
      } else {
        await storageRef.putFile(_imageFile!);
      }
      imageUrl = await storageRef.getDownloadURL();
    }
    
    final newApodo = _apodoController.text;

    // Update user data
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nombre': _nombreController.text,
      'apellidos': _apellidosController.text,
      'apodo': newApodo,
      if (imageUrl != null) 'fotoPerfil': imageUrl,
    });

    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }

    // Update userApodo in locations
    final userLocations = await FirebaseFirestore.instance
        .collection('locations')
        .where('userEmail', isEqualTo: user.email)
        .get();

    for (var location in userLocations.docs) {
      await location.reference.update({
        'userApodo': newApodo,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar datos"),
        backgroundColor: const Color.fromARGB(255, 63, 214, 63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : AssetImage('lib/images/PerfilUser.png'))) as ImageProvider,
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text('Cambiar foto de perfil'),
              ),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _apellidosController,
                decoration: InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: _apodoController,
                decoration: InputDecoration(labelText: 'Apodo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




