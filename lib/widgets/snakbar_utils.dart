import 'package:flutter/material.dart';

void showCustomSnackbar(
  BuildContext context,
  String message,
) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(
        color: Color(0xFFf3f8fc),
        fontSize: 16,
      ),
    ),
    backgroundColor: const Color(0xFF256b8e),
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
