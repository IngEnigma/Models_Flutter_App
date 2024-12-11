import 'package:flutter/material.dart';

Widget buildTextField(String label, TextEditingController controller,
    {bool obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF256b8e)),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Color(0xFF152D3C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Color(0xFF256b8e), width: 3.0),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
