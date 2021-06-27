import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/common/snackBarTheme.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/setGameWidgets.dart';
import 'common/textTheme.dart';
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
            child: SetGameLevel(level: notifier.level, title: "Game Level"),
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
                Flexible(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        notifier.loading = true;
                        if (notifier.level.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBarThemeStyle.chooseGameLevel);
                          notifier.loading = false;
                          return;
                        }
                        context
                            .read(createRoomProvider!.future)
                            .then(
                              (value) async {
                                await context.read(joinRoomProvider.future);
                                context.read(pageProvider).replace(
                                    GameRoom.toMaterialPage(id: value));
                              },
                            )
                            .whenComplete(() => notifier.loading = false)
                            .catchError(
                              (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'There is some issue while creating room',
                                      style: TextStyleFontTheme.poppins,
                                    ),
                                    duration: DurationCount.sec1,
                                  ),
                                );
                              },
                            );
                      },
                      child: StartGameText(),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
