import 'package:flutter/material.dart';

class MyFunct {
  // Show and error message
  static void showErrorMessage(String message0, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message0,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red,
    ));
  }

  // Show a message
  static void showMessage(String message0, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message0,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: Theme.of(context).primaryColor,
    ));
  }
}
