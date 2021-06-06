import 'package:flutter/material.dart';

import 'textTheme.dart';

class SnackBarThemeStyle {
  static SnackBar waitForOthers() => SnackBar(
        backgroundColor: Colors.brown[900],
        elevation: 8,
        duration: const Duration(seconds: 1),
        content: FractionallySizedBox(
          heightFactor: 0.025,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              "Wait for other Players",
              style: TextStyleFontTheme.poppins,
            ),
          ),
        ),
      );

  static SnackBar comingSoon() => SnackBar(
        backgroundColor: Colors.blue[900],
        elevation: 8,
        duration: const Duration(seconds: 1),
        content: FractionallySizedBox(
          heightFactor: 0.025,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              "Coming Soon..",
              style: TextStyleFontTheme.poppins,
            ),
          ),
        ),
      );

  static SnackBar roomCodeError(String error) => SnackBar(
        backgroundColor: Colors.brown[700],
        elevation: 8,
        duration: const Duration(seconds: 1),
        content: FractionallySizedBox(
          heightFactor: 0.04,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              error,
              style: TextStyleFontTheme.poppins,
            ),
          ),
        ),
      );
}
