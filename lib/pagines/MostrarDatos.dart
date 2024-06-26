import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data'; // Importa este paquete para Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;
import 'FilterableMap.dart'; // Importa la página del mapa
import 'CategoriasFiltros.dart' as cat; // Importa categorías y filtros
import 'EditableFollowersList.dart';
import 'EditableFollowingList.dart';
import 'EditableLocationsList.dart'; // Nueva página para editar ubicaciones
import 'EditableEventsList.dart'; // Nueva página para editar eventos

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
  int followersCount = 0;
  int followingCount = 0;
  final String _defaultProfileImage = 'lib/images/PerfilUser.png';

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
    _loadUserData();
    _getFollowersCount();
    _getFollowingCount();
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

  Future<void> _getFollowersCount() async {
    final followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('followers')
        .get();

    setState(() {
      followersCount = followersSnapshot.docs.length;
    });
  }

  Future<void> _getFollowingCount() async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .get();

    setState(() {
      followingCount = followingSnapshot.docs.length;
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
    // Verifica que los campos no estén vacíos
    if (_nombreController.text.isEmpty ||
        _apellidosController.text.isEmpty ||
        _apodoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos deben estar llenos')),
      );
      return;
    }

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

    // Update userApodo in events
    final userEvents = await FirebaseFirestore.instance
        .collection('events')
        .where('createdByEmail', isEqualTo: user.email)
        .get();

    for (var event in userEvents.docs) {
      await event.reference.update({
        'createdBy': newApodo,
      });
    }

    Navigator.pop(context, true); // Pasa un valor true para indicar que se realizaron cambios
  }

  Future<void> _removeProfileImage() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fotoPerfil': null,
    });

    setState(() {
      _profileImageUrl = null;
      _imageFile = null;
      _imageBytes = null;
    });
  }

  void _navigateToEditableFollowers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditableFollowersList(userId: user.uid),
      ),
    );
  }

  void _navigateToEditableFollowing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditableFollowingList(userId: user.uid),
      ),
    );
  }

  void _navigateToEditableLocations(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditableLocationsList(
          userEmail: user.email!,
          onLocationDeleted: _onLocationDeleted,
        ),
      ),
    );
  }

  void _navigateToEditableEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditableEventsList(
          userEmail: user.email!,
          onEventDeleted: _onEventDeleted,
        ),
      ),
    );
  }

  void _onLocationDeleted() async {
    await _updateMap();
  }

  void _onEventDeleted() async {
    await _updateMap();
  }

  Future<void> _updateMap() async {
    // Lógica para actualizar el mapa
  }

  void _showProfileImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Cerrar el diálogo de pantalla completa
            },
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.white);
                },
              ),
            ),
          ),
        );
      },
    );
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
              GestureDetector(
                onTap: () {
                  if (_profileImageUrl != null) {
                    _showProfileImageDialog(_profileImageUrl!);
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage(_defaultProfileImage))) as ImageProvider,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text('Cambiar foto de perfil'),
              ),
              if (_profileImageUrl != null && _profileImageUrl != _defaultProfileImage)
                TextButton(
                  onPressed: _removeProfileImage,
                  child: Text('Eliminar foto'),
                ),
              SizedBox(height: 20),
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
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToEditableFollowers(context),
                    child: Column(
                      children: [
                        Text('$followersCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Seguidores', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToEditableFollowing(context),
                    child: Column(
                      children: [
                        Text('$followingCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Seguidos', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToEditableLocations(context),
                    child: Column(
                      children: [
                        Text('Ubicaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(Icons.location_on, size: 30),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToEditableEvents(context),
                    child: Column(
                      children: [
                        Text('Eventos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(Icons.event, size: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

















