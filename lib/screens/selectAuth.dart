import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/authProvider.dart';
import 'providers/newNameProvider.dart';

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
                            style: TextStyle(
                              fontFamily: 'LuckiestGuy',
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
                          "How would you like to login?",
                          style: TextStyle(
                            fontFamily: 'LuckiestGuy',
                            color: Colors.white60,
                            fontSize: 24,
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

class AuthTextButton extends StatelessWidget {
  final String? btn;
  const AuthTextButton({Key? key, this.btn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
        child: TextButton(
          child: Text(
            btn!,
            style: TextStyle(
              fontFamily: 'LuckiestGuy',
              color: Colors.white60,
              fontSize: 24,
            ),
          ),
          onPressed: () {
            if (btn!.contains("Guest"))
              context.read(anonymousProvider!);
            else
              context.read(googleSignInProvider!);
          },
        ),
      ),
    );
  }
}

/*class AuthButtons extends StatelessWidget {
  final String btn;

  const AuthButtons(this.btn, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 4,
        child: Container(
          alignment: btn.contains("Google")
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.4,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_btnColors(btn)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      btn.contains("Google")
                          ? Icons.mail_outline
                          : Icons.grade_outlined,
                      size: 40,
                      color: Colors.white60,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      btn,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 20, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                if (btn.contains("Guest"))
                  context.read(anonymousProvider!);
                else
                  context.read(googleSignInProvider!);
              },
            ),
          ),
        ),
      );

  Color? _btnColors(String value) =>
      value.contains("Guest") ? Colors.brown[700] : Colors.red[900];
}*/
