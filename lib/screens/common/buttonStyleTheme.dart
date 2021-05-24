import 'package:flutter/material.dart';
import 'package:paricon/screens/common/paddingTheme.dart';

import 'textTheme.dart';

class ButtonStyleTheme {
  static ButtonStyle buildDashboardButtonStyle({Color btncolor}) => ButtonStyle(
        padding: MaterialStateProperty.all(
          EdgeInsets.all(16.0),
        ),
        elevation: MaterialStateProperty.all(4.0),
        side: MaterialStateProperty.all(
          BorderSide(color: Colors.white70, width: 4),
        ),
        backgroundColor: MaterialStateProperty.all(btncolor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
      );

  static ButtonStyle createGameButtonStyle({bool enabled = false}) =>
      ButtonStyle(
        textStyle: MaterialStateProperty.all(
          TextStyleFontTheme.reggaeOne,
        ),
        backgroundColor: MaterialStateProperty.all(
            enabled ? Colors.indigo[300] : Colors.indigo[700]),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        padding: MaterialStateProperty.all(PaddingTheme.all8),
        elevation: MaterialStateProperty.all(8),
      );
}
