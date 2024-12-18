import 'package:app/widgets/custom_title_text_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/text_field_widget.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:app/widgets/logs_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class LogService {
  static Future<List<dynamic>> fetchLogs(BuildContext context,
      {String? username, String? model}) async {
    String getLogsQuery = """
      query GetLogs(\$username: String, \$model: String) {
        allLogs(username: \$username, model: \$model) {
          id
          username
          model
          requestData
          responseData
          timestamp
        }
      }
    """;

    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: gql(getLogsQuery),
      variables: {
        'username': username,
        'model': model,
      },
    );

    final result = await client.query(options);

    if (result.hasException) {
      showCustomSnackbar(context, "Error al realizar la consulta.");
    }

    return result.data?['allLogs'] ?? [];
  }
}

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  String? _selectedUser;
  String? _selectedModel;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  String formatDate(String timestamp) {
    final DateTime date = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  String extractInstances(String? requestData) {
    if (requestData == null) {
      return "No requestData";
    }
    try {
      final data = json.decode(requestData);
      return data['instances']?.toString() ?? "No instances";
    } catch (e) {
      return "Invalid requestData format";
    }
  }

  String extractPredictions(String? responseData) {
    if (responseData == null) {
      return "No responseData";
    }
    try {
      final data = json.decode(responseData);
      return data['predictions']?.toString() ?? "No predictions";
    } catch (e) {
      return "Invalid responseData format";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customTitleText("Models App"),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildTextField(
                  "Username",
                  _userController,
                ),
                buildTextField(
                  "Model",
                  _modelController,
                ),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        final username = _userController.text.trim();
                        final model = _modelController.text.trim();
                        if (username.isNotEmpty || model.isNotEmpty) {
                          setState(() {
                            _selectedUser = username;
                            _selectedModel = model;
                          });
                        } else {
                          showCustomSnackbar(
                              context, "Please enter a username and a model.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF256b8e),
                        disabledBackgroundColor: const Color(0xFF256b8e),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Search",
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
          // Lista de logs
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: LogService.fetchLogs(
                context,
                username: _selectedUser,
                model: _selectedModel,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showCustomSnackbar(context, "Error al cargar los logs.");
                  });
                }

                final List logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showCustomSnackbar(context, "No logs found.");
                  });
                  return const Center(child: Text("No hay logs disponibles"));
                }

                return buildLogList(logs, formatDate);
              },
            ),
          ),
        ],
      ),
    );
  }
}
