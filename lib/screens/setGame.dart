import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/snackBarTheme.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/setGameWidgets.dart';

import 'gameRoom.dart';
import 'providers/pageProvider.dart';
import 'providers/roomProvider.dart';
import 'providers/setGameProvider.dart';

class SetGame extends ConsumerWidget {
  //final bool isGameOnline;

  const SetGame({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
      child: SetGame(), key: ValueKey("setGame"), name: "/setGame");

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = context.read(setGameProvider);
    final setGame = watch(setGameProvider);
    return Container(
      padding: PaddingTheme.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: SetGameLevel(
              level: notifier.level,
              title: "Game Level",
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SetGameTitle(title: "Number of players"),
                Point5Gap(),
                SetPlayerCount(isOnline: true)
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SetGameTitle(title: "Game type"),
                GameTypeButtons(
                  selectedType: notifier.type,
                  isGameOnline: true,
                ),
                SetGameDetails(isOnline: true),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: AnimatedOpacity(
                    opacity: setGame.loading ? 1 : 0,
                    duration: DurationCount.m250,
                    child: CircularProgressIndicator(),
                  ),
                ),
                StartGameButton(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class StartGameButton extends StatelessWidget {
  const StartGameButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final setGame = context.read(setGameProvider);
              setGame.loading = true;
              if (setGame.level.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBarThemeStyle.chooseGameLevel);
                setGame.loading = false;
                return;
              }
              context
                  .read(createRoomProvider!.future)
                  .then((value) async {
                    /* if (value == "UPDATE") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBarThemeStyle.appUpdate,
                      );
                    } else {*/
                    await context.read(joinRoomProvider.future);
                    context
                        .read(pageProvider)
                        .replace(GameRoom.toMaterialPage(id: value));
                    //}
                  })
                  .whenComplete(() => setGame.loading = false)
                  .catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBarThemeStyle.creatingRoomIssue,
                    );
                  });
            },
            child: StartGameText(),
          ),
        ),
      );
}
