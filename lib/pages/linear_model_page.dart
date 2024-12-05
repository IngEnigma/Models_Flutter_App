import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart';
import 'dart:convert';

class LinearModelPage extends StatefulWidget {
  @override
  _LinearModelPageState createState() => _LinearModelPageState();
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
    required String user,
    required String requestData,
    required String responseData,
  }) async {
    const String createLogMutation = """
      mutation CreateLog(\$user: String!, \$requestData: String!, \$responseData: String!) {
        createLog(user: \$user, requestData: \$requestData, responseData: \$responseData) {
          log {
            id
            user
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
            "user": user,
            "requestData": requestData,
            "responseData": responseData,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Por favor ingrese tres números válidos separados por comas.")),
      );
      return;
    }

    final payload = buildPayload();
    final appState = Provider.of<MyAppState>(context, listen: false);
    final user =
        appState.username.isNotEmpty ? appState.username : "Usuario Anónimo";

    setState(() {
      isLoading = true;
    });

    try {
      logger.d("Enviando solicitud de predicción con payload: $payload");
      final result = await sendPredictionRequest(payload);

      setState(() {
        predictionResult = result['predictions']?.toString() ??
            "No se encontraron predicciones.";
      });

      logger.i("Predicción recibida: $result");
      await saveLogToServer(
        context,
        user: user,
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
        user: user,
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
      appBar: AppBar(
        title: const Text("Linear Model"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0),
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
                        predictionResult = "Por favor ingrese números válidos.";
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256b8e),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Hacer Predicción",
                    style: TextStyle(color: Color(0xFFf3f8fc), fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(0.0),
                child: Card(
                  color: const Color(0xFF256b8e),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Result",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFf3f8fc),
                        ),
                      ),
                      if (predictionResult.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          predictionResult,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8)
                      ] else ...[
                        const SizedBox(height: 15),
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFFf3f8fc),
                              )
                            : const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
