import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/common/textTheme.dart';

import 'enterName.dart';
import 'providers/pageProvider.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
      child: Welcome(), key: ValueKey('welCome'), name: '/welcome');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[600],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Spacer(),
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Image.asset(
                    'assets/title_red.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              //WelcomeButtons(),
              WelcomeStartBtn()
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeStartBtn extends StatelessWidget {
  const WelcomeStartBtn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          alignment: Alignment.bottomRight,
          child: FractionallySizedBox(
            heightFactor: 0.3,
            widthFactor: 0.4,
            child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(8),
                ),
                elevation: MaterialStateProperty.all<double>(12.0),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.red[700]),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: FractionallySizedBox(
                heightFactor: 0.6,
                child: FittedBox(
                  child: Text(
                    "START",
                    style: TextStyleFontTheme.luckiestGuy.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              onPressed: () =>
                  context.read(pageProvider).addNext(EnterName.toMaterialPage),
            ),
          ),
        ),
      );
}

class WelcomeButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Flexible(
        flex: 3,
        child: Column(
          children: const ["New Account", "Existing Account"]
              .map(
                (btn) => Flexible(
                  flex: 2,
                  child: Align(
                    alignment: btn.contains("New")
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      heightFactor: 0.2,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red[200]),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          child: FittedBox(
                            child: Text(
                              btn,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      fontSize: 16, color: Colors.black87),
                            ),
                          ),
                          onPressed: () => context
                              .read(pageProvider)
                              .addNext(EnterName.toMaterialPage)),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
}
