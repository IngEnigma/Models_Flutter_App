import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'dart:io';

class FacesModelPage extends StatefulWidget {
  @override
  _FacesModelPageState createState() => _FacesModelPageState();
}

class _FacesModelPageState extends State<FacesModelPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _predictImage() async {
    if (_selectedImage != null) {
      logger.d("Realizando predicción...");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, selecciona una imagen primero.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faces Model'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(20),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      "Cámara",
                      style: TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                    ),
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256b8e),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text(
                      "Subir archivo",
                      style: TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                    ),
                    onPressed: _selectFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256b8e),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text(
                      "Predict",
                      style: TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                    ),
                    onPressed: _predictImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256b8e),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
