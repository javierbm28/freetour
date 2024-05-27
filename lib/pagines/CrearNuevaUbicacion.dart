import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart' as cat;
import 'package:flutter/foundation.dart'; // Importa foundation.dart para kIsWeb
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mime/mime.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrearNuevaUbicacion extends StatefulWidget {
  final LatLng latLng;
  final Function(LatLng) onLocationSaved;

  CrearNuevaUbicacion({required this.latLng, required this.onLocationSaved});

  @override
  _CrearNuevaUbicacionState createState() => _CrearNuevaUbicacionState();
}

class _CrearNuevaUbicacionState extends State<CrearNuevaUbicacion> {
  final TextEditingController _nombreController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  List<String> _subcategories = [];
  File? _imageFile;
  Uint8List? _imageBytes; // Para web
  final picker = ImagePicker();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Nueva Ubicación"),
        backgroundColor: Color.fromARGB(255, 63, 214, 63), // Color del encabezado
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 400), // Limitar el ancho máximo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre del lugar",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _updateSubcategories(newValue);
                    });
                  },
                  items: cat.categories.map<DropdownMenuItem<String>>((cat.Category category) {
                    return DropdownMenuItem<String>(
                      value: category.name,
                      child: Text(category.name),
                    );
                  }).toList(),
                ),
                if (_subcategories.isNotEmpty)
                  SizedBox(height: 20),
                if (_subcategories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedSubcategory,
                    decoration: InputDecoration(
                      labelText: "Subcategoría",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubcategory = newValue;
                      });
                    },
                    items: _subcategories.map<DropdownMenuItem<String>>((String subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.grey,
                    elevation: 5,
                  ),
                ),
                SizedBox(height: 20),
                if (_imageFile != null)
                  Image.file(_imageFile!),
                if (_imageBytes != null)
                  Image.memory(_imageBytes!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _validateAndUpload,
                  child: Text('Guardar Ubicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.grey,
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateSubcategories(String? category) {
    if (category == null) {
      _subcategories = [];
    } else {
      int index = cat.categories.indexWhere((c) => c.name == category);
      if (index != -1) {
        _subcategories = cat.categories[index].subcategories.keys.toList();
      }
    }
    _selectedSubcategory = null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _imageBytes = await pickedFile.readAsBytes();
      } else {
        _imageFile = File(pickedFile.path);
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecciona un archivo de imagen.')));
    }
  }

  Future<void> _validateAndUpload() async {
    if (_nombreController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedSubcategory == null ||
        (_imageFile == null && _imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    String mimeType;
    if (kIsWeb) {
      mimeType = lookupMimeType('', headerBytes: _imageBytes)!;
    } else {
      mimeType = lookupMimeType(_imageFile!.path)!;
    }

    if (!mimeType.startsWith('image/')) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El archivo seleccionado no es una imagen')));
      return;
    }

    String imageUrl = await _uploadImageToStorage();

    final currentUser = user;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      final apodo = userData?['apodo'] ?? 'Sin apodo';

      await FirebaseFirestore.instance.collection('locations').add({
        'name': _nombreController.text,
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'imageUrl': imageUrl,
        'coordinates': GeoPoint(widget.latLng.latitude, widget.latLng.longitude),
        'userEmail': currentUser.email, // Guardar el correo del usuario
        'userApodo': apodo, // Guardar el apodo del usuario
      });

      widget.onLocationSaved(widget.latLng);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se ha podido autenticar al usuario.')));
    }
  }

  Future<String> _uploadImageToStorage() async {
    String filePath = 'images/${DateTime.now().millisecondsSinceEpoch}.png'; // Define your own storage path
    Reference ref = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask =
        kIsWeb ? ref.putData(_imageBytes!) : ref.putFile(_imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}




