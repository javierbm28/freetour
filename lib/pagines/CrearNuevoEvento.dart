import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrearNuevoEvento extends StatefulWidget {
  final LatLng latLng;
  final Function onEventAdded;

  CrearNuevoEvento({required this.latLng, required this.onEventAdded});

  @override
  _CrearNuevoEventoState createState() => _CrearNuevoEventoState();
}

class _CrearNuevoEventoState extends State<CrearNuevoEvento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  Uint8List? _webImage; // Almacenar la imagen en la web como Uint8List
  final picker = ImagePicker();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? mimeType;
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
        mimeType = lookupMimeType('', headerBytes: _webImage);
      } else {
        _imageFile = File(pickedFile.path);
        mimeType = lookupMimeType(_imageFile!.path);
      }
      if (mimeType != null && mimeType.startsWith('image/')) {
        setState(() {});
      } else {
        setState(() {
          _webImage = null;
          _imageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecciona un archivo de imagen válido.')),
        );
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        (_imageFile != null || _webImage != null)) {
      String? imageUrl;
      if (_imageFile != null || _webImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('event_images').child('${DateTime.now()}.jpg');
        if (kIsWeb && _webImage != null) {
          await storageRef.putData(_webImage!);
        } else if (_imageFile != null) {
          await storageRef.putFile(_imageFile!);
        }
        imageUrl = await storageRef.getDownloadURL();
      }

      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final currentUser = user;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        final userData = userDoc.data();
        final apodo = userData?['apodo'] ?? 'Sin apodo';
        final email = currentUser.email ?? 'Sin email';

        await FirebaseFirestore.instance.collection('events').add({
          'title': _tituloController.text,
          'description': _descripcionController.text,
          'dateTime': eventDateTime,
          'imageUrl': imageUrl,
          'coordinates': GeoPoint(widget.latLng.latitude, widget.latLng.longitude),
          'createdBy': apodo,
          'createdByEmail': email,
          'participants': [],
        });

        widget.onEventAdded();
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se ha podido autenticar al usuario.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor complete todos los campos y adjunte una imagen.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear nuevo evento'),
        backgroundColor: Color.fromARGB(255, 63, 214, 63),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título del evento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un título';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una descripción';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _selectDateTime(context),
                    child: Text(
                      _selectedDate == null || _selectedTime == null
                          ? 'Seleccione fecha y hora'
                          : '${DateFormat.yMd().format(_selectedDate!)} ${_selectedTime!.format(context)}',
                    ),
                  ),
                  SizedBox(height: 20),
                  _imageFile == null && _webImage == null
                      ? Text('No hay imagen seleccionada.')
                      : kIsWeb
                          ? Image.memory(_webImage!)
                          : Image.file(_imageFile!),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Adjuntar imagen'),
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
                  ElevatedButton(
                    onPressed: _saveEvent,
                    child: Text('Guardar evento'),
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
      ),
    );
  }
}



