import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'durationCount.dart';
import 'textTheme.dart';

class SnackBarThemeStyle {
  static SnackBar get waitForOthers => SnackBar(
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

  static SnackBar get comingSoon => SnackBar(
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
          heightFactor: 0.025,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            child: Text(
              error,
              style: TextStyleFontTheme.poppins,
            ),
          ),
        ),
      );

  static SnackBar get chooseGameLevel => SnackBar(
        content: Text(
          'Choose Game Level',
          style: TextStyleFontTheme.poppins,
        ),
        duration: DurationCount.m500,
      );

  static SnackBar get creatingRoomIssue => SnackBar(
        content: Text(
          'There is some issue while creating room',
          style: TextStyleFontTheme.poppins,
        ),
        duration: DurationCount.sec1,
      );

  static SnackBar get appUpdate => SnackBar(
        content: Text("Update Available"),
        action: SnackBarAction(
          label: "UPDATE",
          textColor: Colors.green,
          onPressed: () => InAppUpdate.performImmediateUpdate(),
        ),
        duration: DurationCount.sec1,
      );
}
