import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastName1Controller = TextEditingController();
  final lastName2Controller = TextEditingController();
  final phoneMobileController = TextEditingController();

  File? _profileImage;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadProfileImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();

    bool emailExists = await checkEmailExists(email);

    String? imageURL;

    if (_profileImage != null) {
      imageURL = await uploadProfileImage(_profileImage!);
    }

    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El email ya está registrado")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').add({
      'email': email,
      'userName': userNameController.text.trim(),
      'firstName': firstNameController.text.trim(),
      'middleName': middleNameController.text.trim(),
      'lastName1': lastName1Controller.text.trim(),
      'lastName2': lastName2Controller.text.trim(),
      'phoneMobile': phoneMobileController.text.trim(),
      'profileImageURL': imageURL,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usuario registrado exitosamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: userNameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de usuario'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Primer Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa su nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: middleNameController,
                  decoration:
                      const InputDecoration(labelText: 'Segundo Nombre'),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: lastName1Controller,
                  decoration:
                      const InputDecoration(labelText: 'Primer Apellido'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa su apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: lastName2Controller,
                  decoration:
                      const InputDecoration(labelText: 'Segundo Apellido'),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: phoneMobileController,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un número telefonico';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/fondo_blanco.jpg')
                              as ImageProvider, // Imagen por defecto
                      child: _profileImage == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Llamar a la función de registro
                      await registerUser();
                    }
                  },
                  child: const Text('Registrar Usuario'),
                ),
              ],
            ),
          )),
    );
  }
}
