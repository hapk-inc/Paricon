import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paricon/models/localPlayer.dart';
import 'dashboard.dart';
import 'providers/pageProvider.dart';
import 'common/durationCount.dart';
import 'common/gameBoardWidgets.dart';
import 'common/paddingTheme.dart';

import 'common/textTheme.dart';
import 'providers/gameIconProvider.dart';
import 'providers/practiceProvider.dart';
import 'common/popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PracticeBoard extends StatelessWidget {
  const PracticeBoard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
    child: PracticeBoard(),
    key: ValueKey('practiceBoard'),
    name: '/practiceBoard',
  );

  @override
  Widget build(BuildContext context) {
    final ctx = context.read(practiceProvider);

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => await showDialog(
          context: context,
          builder: (_) => ExitPractice(),
        ),
        child: ProviderListener(
          provider: practiceProvider,
          onChange: (BuildContext context, PracticeNotifier notifier) {
            if (notifier.isGameOver) {
              //context.read(pageProvider).replace(GameResults.toMaterialPage);
              showDialog(
                context: context,
                //barrierDismissible: false,
                builder: (_) => WinPopUp(winners: notifier.winners),
              );
            }
          },
          child: SafeArea(
            child: Consumer(
              builder: (_, watch, c) {
                final watchPractice = watch(practiceProvider);
                return AnimatedContainer(
                  padding: PaddingTheme.all8,
                  duration: DurationCount.m500,
                  color: context
                      .read(gameIconProvider)
                      .iconColor(ctx.players[watchPractice.currentIndex].color)
                      .withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PlayerNameState(
                        player: ctx.players[watchPractice.currentIndex],
                        keyValue: watchPractice.currentIndex,
                      ),
                      GridIcons(
                        icons: watchPractice.icons,
                        isOnline: false,
                      ),
                      PlayerListWheel(
                        players: watchPractice.players,
                        isOnline: false,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WinPopUp extends StatelessWidget {
  final List<LocalPlayer> winners;

  const WinPopUp({Key? key, required this.winners}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.indigo[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        actionsPadding: PaddingTheme.all4,
        titleTextStyle: TextStyleFontTheme.luckiestGuy.copyWith(
          color: Colors.white70,
          fontSize: 24,
          letterSpacing: 2,
        ),
        title: Center(child: Text("Congratulations")),
        content: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            child: Column(
              children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: PaddingTheme.all16,
                    child: Lottie.asset(
                      'assets/lottie/trophy.json',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: PaddingTheme.all8,
                    constraints: BoxConstraints.expand(),
                    child: FittedBox(
                      child: Text(
                        strConversion(winners),
                        style:
                            TextStyleFontTheme.poppins.copyWith(fontSize: 24),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read(pageProvider).replaceAll(Dashboard.toMaterialPage);
            },
            child: Text(
              "Exit Game".toUpperCase(),
              style: TextStyleFontTheme.poppins.copyWith(
                fontSize: 16,
                color: Colors.white38,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final xIcons = context.read(gameIconProvider);
              final practice = context.read(practiceProvider);
              practice.createPracticeBoard(
                xIcons.generateIcons(practice.level),
              );
              Navigator.pop(context, true);
            },
            child: Text(
              "PLAY AGAIN",
              style: TextStyleFontTheme.poppins.copyWith(
                fontSize: 20,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      );

  String strConversion(List<LocalPlayer> winners) => winners.length == 1
      ? winners.first.name.toString()
      : winners.fold(
          "",
          (previousValue, element) => previousValue.isEmpty
              ? element.name.toString() + ", "
              : previousValue +
                  (element != winners.last
                      ? element.name.toString() + ", "
                      : "and ${element.name.toString()}"),
        );
}
