import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/snackBarTheme.dart';
import 'common/textTheme.dart';
import 'providers/authProvider.dart';
import 'providers/connectivityProvider.dart';
import 'providers/newNameProvider.dart';

const String howLogin = "How would you like to login?";

class SelectAuth extends StatelessWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
        child: SelectAuth(),
        key: ValueKey('selectAuth'),
        name: '/selectAuth',
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.green[600],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            text: "Hi ",
                            style: TextStyleFontTheme.luckiestGuy.copyWith(
                              color: Colors.white60,
                              fontSize: 36,
                            ),
                            children: [
                              TextSpan(
                                text: context.read(newNameNotifier),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          howLogin,
                          style: TextStyleFontTheme.poppins.copyWith(
                            color: Colors.white60,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ] +
                  const ["Google Sign In", "As Guest"]
                      .map(
                        (_btn) => AuthTextButton(btn: _btn),
                      )
                      .toList(),
            ),
          ),
        ),
      );
}

const String GOOGLESIGNINERROR =
    "There is some issue while using google sign-in";
const String netIssue = "Please Check your internet connection";

class AuthTextButton extends StatelessWidget {
  final String? btn;
  const AuthTextButton({Key? key, this.btn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivity = context.read(connectivityProvider);
    return Flexible(
      child: FractionallySizedBox(
        child: TextButton(
          child: Text(
            btn!,
            style: TextStyleFontTheme.luckiestGuy.copyWith(
              color: Colors.white60,
              fontSize: 24,
            ),
          ),
          onPressed: () async {
            if (connectivity.connectivityResult != ConnectivityResult.none) {
              if (btn!.contains("Guest"))
                context.read(anonymousProvider!);
              else
                context.read(googleSignInProvider!.future).onError(
                  (Error err, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarThemeStyle.roomCodeError(GOOGLESIGNINERROR),
                    );
                  },
                );
            } else
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBarThemeStyle.roomCodeError(netIssue));
          },
        ),
      ),
    );
  }
}
