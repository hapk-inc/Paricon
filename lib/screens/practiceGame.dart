import 'package:flutter/material.dart';
import 'common/durationCount.dart';
import 'common/gameBoardWidgets.dart';
import 'common/paddingTheme.dart';

import 'common/textTheme.dart';
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
                builder: (_) => WinPopUp(),
              );
            }
          },
          child: SafeArea(
            child: AnimatedContainer(
              padding: PaddingTheme.all8,
              duration: DurationCount.m500,
              child: Consumer(
                builder: (context, watch, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PlayerNameState(
                      player: ctx.players[watch(practiceProvider).currentIndex],
                      keyValue: watch(practiceProvider).currentIndex,
                    ),
                    GridIcons(
                      icons: watch(practiceProvider).icons,
                      isOnline: false,
                    ),
                    PlayerList(
                      players: watch(practiceProvider).players,
                      isOnline: false,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WinPopUp extends ConsumerWidget {
  const WinPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) => AlertDialog(
        backgroundColor: Colors.indigo[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        actionsPadding: PaddingTheme.all4,
        titleTextStyle: TextStyleFontTheme.poppins
            .copyWith(color: Colors.white70, fontSize: 24),
        title: Text("Congratulations ${watch(practiceProvider).winner}"),
        content: FractionallySizedBox(
          heightFactor: 0.1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Leaving at middle of the Game?",
              style: TextStyleFontTheme.poppins.copyWith(fontSize: 20),
              maxLines: 2,
            ),
          ),
        ),
      );
}
