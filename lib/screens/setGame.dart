import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/buttonStyleTheme.dart';
import 'common/textTheme.dart';
import 'gameRoom.dart';
import 'providers/pageProvider.dart';
import 'providers/roomNotifierProvider.dart';
import 'providers/roomProvider.dart';
import 'providers/setGameProvider.dart';

class SetGame extends ConsumerWidget {
  final bool isGameOnline;

  const SetGame({Key? key, this.isGameOnline = false}) : super(key: key);
  static MaterialPage get toMaterialPage => MaterialPage(
        child: SetGame(),
        key: ValueKey('setGame'),
        name: '/setGame',
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final setGame = watch(setGameProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        CreateGameTitleWidget(title: "Set Game Level"),
        Spacer(),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const ["Easy", "Medium", "Hard"]
                .map(
                  (level) => Flexible(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: 0.9,
                      child: ElevatedButton(
                        style: ButtonStyleTheme.createGameButtonStyle(
                            enabled: setGame.level != level),
                        onPressed: () => setGame.level = level,
                        child: Container(
                          constraints: BoxConstraints.expand(),
                          child: FittedBox(
                            child: Text(level),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Spacer(),
        CreateGameTitleWidget(title: "Set Number of players"),
        Flexible(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PlayerAdjustButton(
                icon: Icons.chevron_left,
                iconClick: setGame.playerCount == 2
                    ? null
                    : () => setGame.playerCount--,
              ),
              Flexible(
                flex: 4,
                child: FittedBox(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      "${setGame.playerCount}",
                      key: ValueKey(setGame.playerCount),
                      style: TextStyleFontTheme.luckiestGuy.copyWith(
                        color: Colors.indigo[200],
                        fontSize: 72,
                      ),
                    ),
                  ),
                ),
              ),
              PlayerAdjustButton(
                icon: Icons.chevron_right,
                iconClick: setGame.playerCount == 6
                    ? null
                    : () => setGame.playerCount++,
              ),
            ],
          ),
        ),
        Flexible(
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: ElevatedButton(
                    style: ButtonStyleTheme.createGameButtonStyle(),
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          "Start Game",
                          textScaleFactor: 2,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      context.read(roomNotifierProvider).loading = true;
                      await context.read(createRoomProvider!.future).then(
                        (value) async {
                          await context.read(joinRoomProvider!.future);
                          context
                              .read(pageProvider)
                              .addNext(GameRoom.toMaterialPage(id: value));
                        },
                      ).whenComplete(() =>
                          context.read(roomNotifierProvider).loading = false);
                    }),
              ),
              Spacer(),
              Flexible(
                child: Consumer(
                  builder: (context, watch, child) => AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: watch(roomNotifierProvider).loading ? 1 : 0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class PlayerAdjustButton extends StatelessWidget {
  const PlayerAdjustButton({Key? key, this.iconClick, this.icon})
      : super(key: key);
  final IconData? icon;
  final VoidCallback? iconClick;

  @override
  Widget build(BuildContext context) => Flexible(
        child: IconButton(
          constraints: BoxConstraints.expand(),
          icon: FittedBox(
            child: Icon(icon),
          ),
          color: Colors.white70,
          iconSize: 36,
          onPressed: iconClick,
        ),
      );
}

class CreateGameTitleWidget extends StatelessWidget {
  final String? title;
  const CreateGameTitleWidget({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: FittedBox(
          child: Text(
            title!,
            style: TextStyleFontTheme.reggaeOne.copyWith(
              color: Colors.white54,
            ),
            textScaleFactor: 2,
          ),
        ),
      );
}
