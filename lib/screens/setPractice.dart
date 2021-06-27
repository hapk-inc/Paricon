import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/common/snackBarTheme.dart';

import 'common/paddingTheme.dart';
import 'common/setGameWidgets.dart';

import 'practiceGame.dart';
import 'providers/gameIconProvider.dart';
import 'providers/pageProvider.dart';
import 'providers/practiceProvider.dart';

class SetPractice extends StatelessWidget {
  const SetPractice({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: SetPractice(),
        key: ValueKey('setPractice'),
        name: '/setPractice',
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: Consumer(
            builder: (ctx, watch, child) => Container(
              padding: PaddingTheme.all16,
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: SetGameLevel(
                      title: 'Game Level',
                      level: watch(practiceProvider).level,
                      isOnline: false,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SetGameTitle(title: "Number of players"),
                        Point5Gap(),
                        SetPlayerCount(isOnline: false),
                      ],
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SetGameTitle(title: "Game type"),
                          Point5Gap(),
                          GameTypeButtons(
                            selectedType: ctx.read(practiceProvider).type,
                            isGameOnline: false,
                          ),
                          Point5Gap(),
                          SetGameDetails(isOnline: false),
                        ],
                      )),
                  Flexible(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final notifier = ctx.read(practiceProvider);

                          if (notifier.level.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBarThemeStyle.chooseGameLevel);
                            return;
                          }

                          final xIcons = ctx.read(gameIconProvider);
                          notifier.createBoard(
                              xIcons.generateIcons(notifier.level));

                          ctx
                              .read(pageProvider)
                              .replace(PracticeBoard.toMaterialPage);
                        },
                        child: StartGameText(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
