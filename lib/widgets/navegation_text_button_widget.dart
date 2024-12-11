import 'package:flutter/material.dart';

Widget navigationTextButton({
  required BuildContext context,
  required String buttonText,
  required String routeName,
}) {
  return Center(
    child: TextButton(
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Text(
        buttonText,
        style: const TextStyle(color: Color(0xFF256b8e), fontSize: 16),
      ),
    ),
  );
}
