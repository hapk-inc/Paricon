import 'package:flutter/material.dart';
import 'package:paricon/screens/common/textTheme.dart';

class SnackBarThemeStyle {
  static SnackBar comingSoon() => SnackBar(
        backgroundColor: Colors.blue[900],
        elevation: 8,
        content: FractionallySizedBox(
          heightFactor: 0.05,
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
