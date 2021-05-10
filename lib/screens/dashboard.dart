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
        backgroundColor: Colors.purple[200],
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
                            flex: 4,
                            child: Image.asset(
                              'assets/title_purple.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () => context
                                  .read(pageProvider)
                                  .addNext(ProfileScreen.toMaterialPage),
                              icon: Icon(
                                Icons.person,
                                size: 48,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] +
                  /*[
                    if (!context.read(prevStatsProvider).isWinner)
                      Flexible(
                          child: FittedBox(
                              child: Text("Congratulation for your last game")))
                  ] +*/
                  ["Practice", "Game Online", "Friends and Strangers"]
                      .asMap()
                      .entries
                      .map((e) => DashboardButtons(e))
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
      child: Container(
        alignment: btn.key.isOdd ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.6,
          child: MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: dashboardBtnColor(btn.value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 8,
            child: ListTile(
              title: Text(
                btn.value,
                textDirection:
                    btn.key.isOdd ? TextDirection.ltr : TextDirection.rtl,
                style: TextStyle(
                  //fontSize: 24,
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                ),
              ),
              subtitle: FittedBox(
                child: Text(
                  dashboardSubtitles(btn.value),
                  textDirection:
                      btn.key.isOdd ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            onPressed: () => btn.value.contains("Online")
                ? context.read(pageProvider).addNext(StartGame.toMaterialPage)
                : ScaffoldMessenger.of(context).showSnackBar(snackBar()),
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
