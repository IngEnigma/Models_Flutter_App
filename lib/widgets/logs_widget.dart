import 'package:flutter/material.dart';

Widget buildLogList(List logs, String Function(String) formatDate) {
  return ListView.builder(
    itemCount: logs.length,
    itemBuilder: (context, index) {
      final log = logs[index];
      return buildLogCard(log, formatDate);
    },
  );
}

String truncateRequestData(String requestData, {int maxLength = 200}) {
  if (requestData.length > maxLength) {
    return requestData.substring(0, maxLength) + '...';
  }
  return requestData;
}

Widget buildLogCard(dynamic log, String Function(String) formatDate) {
  return Card(
    margin: const EdgeInsets.all(8.0),
    color: const Color(0xFF256b8e),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            log['username']?.isNotEmpty ?? false
                ? log['username']
                : 'Usuario desconocido',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFFf3f8fc),
            ),
          ),
          Text(
            formatDate(log['timestamp']),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Color(0xFFf3f8fc),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Modelo: ${log['model']}",
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Color(0xFFf3f8fc),
            ),
          ),
          Text(
            "Solicitud: ${truncateRequestData(log['requestData'])}",
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
}
