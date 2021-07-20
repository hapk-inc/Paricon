import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common/durationCount.dart';
import 'common/gameBoardWidgets.dart';
import 'common/paddingTheme.dart';

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
