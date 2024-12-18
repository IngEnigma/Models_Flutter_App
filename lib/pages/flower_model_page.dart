import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'dart:convert';
import 'dart:io';

class FlowerModelPage extends StatefulWidget {
  @override
  _FlowerModelPageState createState() => _FlowerModelPageState();
}

class _FlowerModelPageState extends State<FlowerModelPage> {
  final String baseUrl =
      'https://tensorflow-flowers-model-00oo.onrender.com/v1/models/flowers-model:predict';
  bool isLoading = false;

  List<String> flowerClasses = [
    'Daisy',
    'Dandelion',
    'Roses',
    'Sunflowers',
    'Tulips'
  ];

  List<List<List<double>>> prepareImage(File imageFile) {
    final List<int> bytes = imageFile.readAsBytesSync();
    final img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("No se pudo decodificar la imagen");
    }

    final img.Image resized = img.copyResize(image, width: 100, height: 100);

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
  String _predictionFlower = "";
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

  Future<void> saveLogToServer(
    BuildContext context, {
    required String username,
    required String requestData,
    required String responseData,
    required String model,
  }) async {
    const String createLogMutation = """
    mutation CreateLog(\$username: String!, \$model: String!, \$requestData: String!, \$responseData: String!) {
      createLog(username: \$username, model: \$model, requestData: \$requestData, responseData: \$responseData) {
        log {
          id
          username
          model
          requestData
          responseData
          timestamp
        }
      }
    }
  """;

    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(createLogMutation),
          variables: {
            "username": username,
            "requestData": requestData,
            "responseData": responseData,
            "model": model,
          },
        ),
      );

      if (result.hasException) {
        logger.e("Error al guardar el log: ${result.exception}");
      } else {
        logger.i("Log guardado exitosamente");
      }
    } catch (e) {
      logger.w("Error inesperado al guardar el log: $e");
    }
  }

  String prepareImageAsString(File imageFile) {
    final List<List<List<double>>> imgData = prepareImage(imageFile);

    return json.encode(imgData);
  }

  Future<void> _predictImage() async {
    if (_selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      final appState = Provider.of<MyAppState>(context, listen: false);
      final username =
          appState.username.isNotEmpty ? appState.username : "Usuario Anónimo";

      try {
        final prediction = await predictImage(_selectedImage!);

        final predictions = prediction['predictions'][0];
        final predictedIndex =
            predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
        final predictedFlower = flowerClasses[predictedIndex];
        final confidence =
            (predictions[predictedIndex] * 100).toStringAsFixed(2);

        setState(() {
          _predictionFlower = predictedFlower;
          _predictionConfidence = confidence;
        });

        final requestDataForLog = json.encode({
          "signature_name": "serving_default",
          "instances": [prepareImageAsString(_selectedImage!)],
        });

        await saveLogToServer(
          context,
          username: username,
          model: "Flowers Model",
          requestData: requestDataForLog,
          responseData: json.encode(prediction),
        );

        logger.i("Predicción realizada: $prediction");
      } catch (e) {
        logger.e("Error en la predicción: $e");

        await saveLogToServer(
          context,
          username: username,
          model: "Flowers Model",
          requestData: "Error al procesar la imagen seleccionada",
          responseData: "Error: $e",
        );

        showCustomSnackbar(context, "Prediction error: $e");
      } finally {
        setState(() {
          isLoading = false;
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
                "Flowers Model",
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
                                  fit: BoxFit.contain,
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
                    SizedBox(
                      height: 50,
                      child: _predictionFlower.isNotEmpty &&
                              _predictionConfidence.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "$_predictionFlower | $_predictionConfidence%",
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
                          fontWeight: FontWeight.bold),
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
                          fontWeight: FontWeight.bold),
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
