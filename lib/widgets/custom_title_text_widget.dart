import 'package:flutter/material.dart';

Widget customTitleText(String text,
    {double fontSize = 32,
    FontWeight fontWeight = FontWeight.bold,
    Color color = const Color(0xFF152D3C)}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ),
  );
}
