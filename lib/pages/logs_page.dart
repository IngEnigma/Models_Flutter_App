import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/drawer_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../main.dart';

class LogsPage extends StatelessWidget {
  String _formatDate(String timestamp) {
    final DateTime date = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  String _extractInstances(String requestData) {
    try {
      final data = json.decode(requestData); // Decodifica JSON
      return data['instances']?.toString() ?? "No instances";
    } catch (e) {
      return "Invalid requestData format";
    }
  }

  String _extractPredictions(String responseData) {
    try {
      final data = json.decode(responseData); // Decodifica JSON
      return data['predictions']?.toString() ?? "No predictions";
    } catch (e) {
      return "Invalid responseData format";
    }
  }

  Future<List<dynamic>> fetchLogs(BuildContext context) async {
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

    logger.d("Realizando la consulta de logs...");
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: gql(getLogsQuery),
    );

    final result = await client.query(options);

    if (result.hasException) {
      logger.e("Error al realizar la consulta: ${result.exception.toString()}");
    }
    logger.d("Consulta de logs realizada exitosamente.");

    return result.data?['allLogs'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchLogs(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar los logs: ${snapshot.error}"),
            );
          }

          final List logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(child: Text("No hay logs disponibles"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                color: const Color(0xFF256b8e),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${log['user']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFFf3f8fc))),
                      Text(
                        _formatDate(log['timestamp']),
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: Color(0xFFf3f8fc)),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Solicitud: ${log['requestData']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Color(0xFFf3f8fc),
                        ),
                      ),
                      Text(
                        "Respuesta: ${log['responseData']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Color(0xFFf3f8fc),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
