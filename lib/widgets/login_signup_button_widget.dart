import 'package:flutter/material.dart';

Widget loginSignUpButton({
  required BuildContext context,
  required bool isLoading,
  required String buttonText,
  required Future<void> Function() onPressed,
}) {
  return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF256b8e),
          disabledBackgroundColor: const Color(0xFF256b8e),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Color(0xFFf3f8fc))
            : Text(
                buttonText,
                style: const TextStyle(
                  color: Color(0xFFf3f8fc),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ));
}
