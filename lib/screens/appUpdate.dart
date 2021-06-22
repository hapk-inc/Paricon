import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'common/buttonStyleTheme.dart';
import 'common/paddingTheme.dart';
import 'common/textTheme.dart';

class AppUpdate extends StatelessWidget {
  const AppUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.red,
        body: Container(
          alignment: Alignment.center,
          padding: PaddingTheme.all8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: AutoSizeText(
                  "Kindly update the app to check the latest updates",
                  textAlign: TextAlign.center,
                  style: TextStyleFontTheme.poppins.copyWith(
                    fontSize: 32,
                    color: Colors.white70,
                  ),
                  minFontSize: 24,
                  maxFontSize: 48,
                ),
              ),
              Spacer(),
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 0.25,
                  child: ElevatedButton(
                    style: ButtonStyleTheme.buildDashboardButtonStyle(
                        btnColor: Colors.red),
                    onPressed: () {
                      InAppUpdate.performImmediateUpdate().catchError(
                        (error, _) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reopen the app again for update.',
                                style: TextStyleFontTheme.poppins,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: AutoSizeText(
                      "Update",
                      style: TextStyleFontTheme.poppins.copyWith(fontSize: 32),
                      minFontSize: 24,
                      maxFontSize: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
