import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/authProvider.dart';
import 'package:paricon/providers/newNameProvider.dart';

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
                              fontFamily: 'MeriendaOne',
                              color: Colors.white60,
                              fontSize: 36,
                            ),
                            /* style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    fontSize: 32, fontWeight: FontWeight.w300),*/
                            children: [
                              TextSpan(
                                text: context.read(newNameNotifier),
                                /* style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),*/
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
                            fontFamily: 'MeriendaOne',
                            color: Colors.white60,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ] +
                  const ["Google Sign In", "As Guest"]
                      .map((btn) => AuthButtons(btn))
                      .toList(),
            ),
          ),
        ),
      );
}

class AuthButtons extends StatelessWidget {
  final String btn;

  const AuthButtons(this.btn, {Key key}) : super(key: key);

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
                          .caption
                          .copyWith(fontSize: 20, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                if (btn.contains("Guest"))
                  context.read(anonymousProvider);
                else
                  context.read(googleSignInProvider);
              },
            ),
          ),
        ),
      );

  Color _btnColors(String value) =>
      value.contains("Guest") ? Colors.brown[700] : Colors.red[900];
}
