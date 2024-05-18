import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart' as cat;
import 'package:flutter/foundation.dart'; // Importa foundation.dart para kIsWeb
import 'package:mapbox_gl/mapbox_gl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Nueva Ubicación"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: "Nombre del lugar"),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
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
              DropdownButton<String>(
                value: _selectedSubcategory,
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
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Seleccionar Imagen'),
            ),
            if (_imageFile != null) Image.file(_imageFile!),
            if (_imageBytes != null) Image.memory(_imageBytes!),
            ElevatedButton(
              onPressed: _uploadLocation,
              child: Text('Guardar Ubicación'),
            ),
          ],
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
    }
  }

  Future<void> _uploadLocation() async {
    if (_nombreController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedSubcategory == null ||
        (_imageFile == null && _imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    String imageUrl = await _uploadImageToStorage();
    await FirebaseFirestore.instance.collection('locations').add({
      'name': _nombreController.text,
      'category': _selectedCategory,
      'subcategory': _selectedSubcategory,
      'imageUrl': imageUrl,
      'coordinates': GeoPoint(widget.latLng.latitude, widget.latLng.longitude),
    });

    widget.onLocationSaved(widget.latLng);
    Navigator.pop(context);
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


