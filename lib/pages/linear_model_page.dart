import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'dart:convert';

class LinearModelPage extends StatefulWidget {
  const LinearModelPage({super.key});
  @override
  State<LinearModelPage> createState() => _LinearModelPageState();
}

class _LinearModelPageState extends State<LinearModelPage> {
  final TextEditingController numbersController = TextEditingController();

  String predictionResult = "";
  bool isLoading = false;

  bool validateInputs() {
    List<String> numbers = numbersController.text.split(',');
    if (numbers.length != 3) return false;
    for (var number in numbers) {
      if (double.tryParse(number.trim()) == null) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> buildPayload() {
    List<String> numbers = numbersController.text.split(',');
    return {
      "instances": [
        [double.tryParse(numbers[0].trim()) ?? 0.0],
        [double.tryParse(numbers[1].trim()) ?? 0.0],
        [double.tryParse(numbers[2].trim()) ?? 0.0],
      ]
    };
  }

  Future<Map<String, dynamic>> sendPredictionRequest(
      Map<String, dynamic> payload) async {
    const String serverUrl =
        'https://tensorflow-linear-model-8tnk.onrender.com/v1/models/linear-model:predict';

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      logger.i("Predicción realizada exitosamente.");
      return json.decode(response.body);
    } else {
      logger.e("Error (${response.statusCode}): ${response.body}");
      throw Exception("Error en la solicitud: ${response.statusCode}");
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

  Future<void> linearModelPredict(BuildContext context) async {
    if (!validateInputs()) {
      logger.w("Entradas inválidas detectadas");
      showCustomSnackbar(
          context, "Please enter three numbers separated by commas.");
      return;
    }

    final payload = buildPayload();
    final appState = Provider.of<MyAppState>(context, listen: false);
    final username =
        appState.username.isNotEmpty ? appState.username : "Usuario Anónimo";

    setState(() {
      isLoading = true;
    });

    try {
      logger.d("Enviando solicitud de predicción con payload: $payload");
      final result = await sendPredictionRequest(payload);

      // Formatear las predicciones separadas por " | "
      List<dynamic> predictions = result['predictions'] ?? [];
      List<String> formattedPredictions = predictions
          .map((prediction) => (prediction as List)
              .map((p) => p is double ? p.toStringAsFixed(2) : p.toString())
              .join(', '))
          .toList();

      setState(() {
        predictionResult = formattedPredictions.join(' | ');
      });

      logger.i("Predicción recibida: $result");
      await saveLogToServer(
        context,
        username: username,
        model: "Linear Model",
        requestData: json.encode(payload),
        responseData: json.encode(result),
      );
    } catch (e) {
      logger.e("Error durante la predicción: $e");

      setState(() {
        predictionResult = "Error: $e";
      });

      await saveLogToServer(
        context,
        username: username,
        model: "Linear Model",
        requestData: json.encode(payload),
        responseData: "Error: $e",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    numbersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Linear Model",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152D3C)),
            ),
            const SizedBox(height: 16),
            const Text("Numbers",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF256b8e))),
            const SizedBox(height: 16),
            TextField(
              controller: numbersController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF152D3C))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide:
                          BorderSide(color: Color(0xFF256b8e), width: 3.0))),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (validateInputs()) {
                      setState(() {
                        isLoading = true;
                      });
                      await linearModelPredict(context);
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      logger.e("Datos Invalidos");
                      setState(() {
                        predictionResult = "Please enter three numbers.";
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256b8e),
                    disabledBackgroundColor: const Color(0xFF256b8e),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          child: CircularProgressIndicator(
                            color: Color(0xFFf3f8fc),
                          ),
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
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  color: const Color(0xFF256b8e),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 13),
                      const Text(
                        "Result",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFf3f8fc),
                        ),
                      ),
                      predictionResult.isNotEmpty
                          ? Column(
                              children: [
                                const SizedBox(height: 14),
                                Text(
                                  predictionResult,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFf3f8fc),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                              ],
                            )
                          : const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
