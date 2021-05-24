import 'package:flutter/material.dart';

class CircularProgressTheme {
  static CircularProgressIndicator get pinkIndicator =>
      CircularProgressIndicator(
        strokeWidth: 5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
      );
}
