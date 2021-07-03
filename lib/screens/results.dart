import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/common/statsValue.dart';

import 'common/paddingTheme.dart';
import 'common/shadedLine.dart';
import 'common/textTheme.dart';
import 'providers/gameIconProvider.dart';
import 'providers/onlineBoardProvider.dart';
import 'providers/roomIDProvider.dart';

class GameResults extends StatelessWidget {
  const GameResults({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: GameResults(),
        name: '/gameResults',
        key: ValueKey('gameResults'),
      );
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read(gameIconProvider);
    final onlineNotifier = context.read(onlineBoardNotifier);
    final winnerColor =
        gameProvider.iconColor(onlineNotifier.sortByPoints.first.color);
    return Scaffold(
      backgroundColor: winnerColor,
      body: WillPopScope(
        onWillPop: () async {
          context.read(idNotifier.notifier).empty();
          //context.read(onlineBoardNotifier).dispose();
          return true;
        },
        child: SafeArea(
          child: Container(
            color: winnerColor.withOpacity(0.75),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      ResultsTitle(title: "Results"),
                      ShadedLine(),
                    ],
                  ),
                ),
                PlayerTable(),
                Flexible(
                  child: Row(
                    children: [
                      ShadedLine(),
                      ResultsTitle(title: "YOUR RESULTS")
                    ],
                  ),
                ),
                MyResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyResults extends StatelessWidget {
  const MyResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.read(onlineBoardNotifier);
    final gIcon = context.read(gameIconProvider);
    return Flexible(
      //flex: 2,
      child: Card(
        elevation: 8,
        color: gIcon.iconBoxColor(notifier.myPlayer!.color),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StatsValue(
                value: notifier.level.toUpperCase(),
                header: "level",
                color: Colors.white70,
              ),
              StatsValue(
                value: notifier.myPlayer!.pts,
                header: "Points",
                color: Colors.white70,
              ),
              StatsValue(
                value: notifier.myAvg,
                header: "Avg. Score",
                color: Colors.white70,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerTable extends StatelessWidget {
  const PlayerTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameIcon = context.read(gameIconProvider);
    final notifier = context.read(onlineBoardNotifier);
    final players = notifier.sortByPoints;

    return Flexible(
      flex: 4,
      child: ListView(
        padding: PaddingTheme.all8,
        children: List.generate(players.length, (index) {
          final _player = players[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
            ),
            height: MediaQuery.of(context).size.height * 0.1,
            transform: Matrix4.rotationZ(index.isOdd ? -0.02 : 0.02),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  tileColor: gameIcon.iconColor(_player.color).withOpacity(0.2),
                  leading: FractionallySizedBox(
                    widthFactor: 0.3,
                    heightFactor: 0.9,
                    child: Center(
                      child: AutoSizeText(
                        _player.name!,
                        style: TextStyleFontTheme.luckiestGuy.copyWith(
                            color: gameIcon.iconColor(_player.color),
                            fontSize: 72),
                        maxLines: 1,
                        minFontSize: 32,
                        maxFontSize: 48,
                      ),
                    ),
                  ),
                  title: FractionallySizedBox(
                    widthFactor: 1,
                    child: Wrap(
                      spacing: 2,
                      children: notifier
                          .coloredIcons(_player.color)
                          .map(
                            (e) => Icon(
                              gameIcon.gameIcon(e.iconCode),
                              size: 16,
                              color: gameIcon.iconColor(e.color),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  trailing: AutoSizeText(
                    _player.pts.toString(),
                    style: TextStyleFontTheme.luckiestGuy.copyWith(
                      fontSize: 48,
                      color: gameIcon.iconColor(_player.color),
                    ),
                    maxLines: 1,
                    minFontSize: 36,
                    maxFontSize: 72,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ResultsTitle extends StatelessWidget {
  final String title;

  const ResultsTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: FittedBox(
          child: Text(
            title,
            style: TextStyleFontTheme.luckiestGuy.copyWith(
              fontSize: 48,
              color: Colors.white70,
            ),
          ),
        ),
      );
}
