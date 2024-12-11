import 'package:image_picker/image_picker.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class FacesModelPage extends StatefulWidget {
  @override
  _FacesModelPageState createState() => _FacesModelPageState();
}

class _FacesModelPageState extends State<FacesModelPage> {
  final String baseUrl =
      'https://tensorflow-faces-model.onrender.com/v1/models/faces-model:predict';
  bool isLoading = false;

  // Clases de caras (ajustar según las clases de tu modelo)
  List<String> faceClasses = ['Enigma', 'Nayelli'];

  List<List<List<double>>> prepareImage(File imageFile) {
    final List<int> bytes = imageFile.readAsBytesSync();
    final img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("No se pudo decodificar la imagen");
    }

    final img.Image resized = img.copyResize(image, width: 128, height: 128);

    List<List<List<double>>> imgData = [];
    for (int y = 0; y < resized.height; y++) {
      List<List<double>> row = [];
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        row.add([r, g, b]);
      }
      imgData.add(row);
    }

    return imgData;
  }

  Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      final List<List<List<double>>> inputData = prepareImage(imageFile);

      final Map<String, dynamic> data = {
        "signature_name": "serving_default",
        "instances": [inputData],
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      throw Exception("Error al realizar la predicción: $e");
    }
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _predictionFace = "";
  String _predictionConfidence = "";

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
      setState(() {
        isLoading = true; // Activar indicador de carga
      });

      try {
        final prediction = await predictImage(_selectedImage!);

        final predictions =
            prediction['predictions'][0]; // Cambia según tu respuesta
        final predictedIndex = predictions.indexOf(predictions.reduce((a, b) =>
            a > b ? a : b)); // Encontramos el índice con mayor certeza
        final predictedFace = faceClasses[
            predictedIndex]; // Usamos el índice para obtener el nombre de la cara
        final confidence = (predictions[predictedIndex] * 100)
            .toStringAsFixed(2); // Confianza en porcentaje

        setState(() {
          _predictionFace = predictedFace;
          _predictionConfidence = confidence;
        });
      } catch (e) {
        debugPrint("Error en la predicción: $e");
      } finally {
        setState(() {
          isLoading = false; // Desactivar indicador de carga
        });
      }
    } else {
      showCustomSnackbar(context, "Please select or take an image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Faces Model",
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFF152D3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(20),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 350,
                width: double.infinity,
                color: const Color(0xFF256b8e),
                child: Column(
                  children: [
                    // Imagen
                    Expanded(
                      child: _selectedImage != null
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.black54,
                                size: 50,
                              ),
                            ),
                    ),
                    // Espacio reservado para el resultado de la predicción
                    SizedBox(
                      height: 50,
                      child: _predictionFace.isNotEmpty &&
                              _predictionConfidence.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "$_predictionFace | $_predictionConfidence%",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    label: const Text(
                      "Camera",
                      style: TextStyle(
                        color: Color(0xFFf3f8fc),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: isLoading ? null : _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256b8e),
                      disabledBackgroundColor: const Color(0xFF256b8e),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    label: const Text(
                      "Upload",
                      style: TextStyle(
                        color: Color(0xFFf3f8fc),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: isLoading ? null : _selectFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256b8e),
                      disabledBackgroundColor: const Color(0xFF256b8e),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _predictImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF256b8e),
                        disabledBackgroundColor: const Color(0xFF256b8e),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFFf3f8fc),
                            )
                          : const Text(
                              "Predict",
                              style: TextStyle(
                                color: Color(0xFFf3f8fc),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
