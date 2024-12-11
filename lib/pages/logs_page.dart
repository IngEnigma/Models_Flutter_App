import 'package:app/widgets/custom_title_text_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:app/widgets/snakbar_utils.dart';
import 'package:app/widgets/drawer_widget.dart';
import 'package:app/widgets/logs_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class LogService {
  static Future<List<dynamic>> fetchLogs(BuildContext context) async {
    const String getLogsQuery = """
      query {
        allLogs {
          id
          user
          requestData
          responseData
          timestamp
        }
      }
    """;

    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: gql(getLogsQuery),
    );

    final result = await client.query(options);

    if (result.hasException) {
      showCustomSnackbar(context, "Error al realizar la consulta.");
    }
    return result.data?['allLogs'] ?? [];
  }
}

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  String formatDate(String timestamp) {
    final DateTime date = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  String extractInstances(String requestData) {
    try {
      final data = json.decode(requestData);
      return data['instances']?.toString() ?? "No instances";
    } catch (e) {
      return "Invalid requestData format";
    }
  }

  String extractPredictions(String responseData) {
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
        backgroundColor: const Color.fromARGB(255, 212, 241, 255),
        title: customTitleText(
          "Models App",
        ),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: customTitleText("Logs")),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: LogService.fetchLogs(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  showCustomSnackbar(context, "Error al cargar los logs.");
                }
                final List logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  showCustomSnackbar(context, "No logs found.");
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
