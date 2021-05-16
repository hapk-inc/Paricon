import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/pageProvider.dart';

import 'profile.dart';
import 'startGame.dart';

class Dashboard extends StatelessWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
        child: Dashboard(),
        key: ValueKey('dashBoard'),
        name: '/dashboard',
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.purple[100],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Flexible(
                            flex: 5,
                            child: FractionallySizedBox(
                              widthFactor: 0.8,
                              child: Image.asset(
                                'assets/title_purple.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              heightFactor: 0.4,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read(pageProvider)
                                    .addNext(ProfileScreen.toMaterialPage),
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(120.0),
                                    ),
                                  ),
                                  elevation: MaterialStateProperty.all(8.0),
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.purple[100],
                                  ),
                                ),
                                child: FittedBox(
                                  child: Icon(
                                    Icons.person,
                                    size: 128,
                                    color: Colors.purple[800],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] +
                  const ["Practice", "Game Online", "Friends and Strangers"]
                      .asMap()
                      .entries
                      .map(
                        (e) => DashboardButtons(e),
                      )
                      .toList(),
            ),
          ),
        ),
      );
}

class DashboardButtons extends StatelessWidget {
  final MapEntry<int, String> btn;

  DashboardButtons(this.btn);

  @override
  Widget build(BuildContext context) {
    SnackBar snackBar() => SnackBar(
          backgroundColor: Colors.blue[900],
          elevation: 8,
          content: SizedBox(
            height: 20,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              child: Text(
                "COMING SOON..",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(letterSpacing: 5),
              ),
            ),
          ),
        );
    return Flexible(
      child: Align(
        alignment: btn.key.isOdd ? Alignment.centerLeft : Alignment.centerRight,
        child: Card(
          color: dashboardBtnColor(btn.value),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.6,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment:
                  btn.key.isOdd ? Alignment.centerLeft : Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => btn.value.contains("Online")
                    ? context
                        .read(pageProvider)
                        .addNext(StartGame.toMaterialPage)
                    : ScaffoldMessenger.of(context).showSnackBar(snackBar()),
                child: Column(
                  crossAxisAlignment: btn.key.isOdd
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Spacer(),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        child: Text(
                          btn.value,
                          textDirection: btn.key.isOdd
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 120,
                            fontFamily: 'Poppins',
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        child: Text(
                          dashboardSubtitles(btn.value),
                          textDirection: btn.key.isOdd
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 120,
                            fontFamily: 'LuckiestGuy',
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String dashboardSubtitles(String btn) => btn == "Practice"
      ? "Play Local Game"
      : btn.contains("Online")
          ? "Play with your friends"
          : "Search for other Players";

  Color dashboardBtnColor(String btn) => btn == "Practice"
      ? Colors.red[900]
      : btn.contains("Online")
          ? Colors.indigo
          : Colors.brown;
}
