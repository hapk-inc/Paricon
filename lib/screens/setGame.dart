import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/textTheme.dart';
import 'gameRoom.dart';
import 'providers/pageProvider.dart';
import 'providers/roomProvider.dart';
import 'providers/setGameProvider.dart';

class SetGame extends ConsumerWidget {
  final bool isGameOnline;

  const SetGame({Key? key, this.isGameOnline = false}) : super(key: key);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CreateGameTitle(title: "Game level"),
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Container(),
                  ),
                ),
                Flexible(
                    child: Center(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["easy", "medium", "hard"]
                        .map(
                          (e) => TextButton(
                            onPressed: () => notifier.level = e,
                            child: AnimatedDefaultTextStyle(
                              duration: DurationCount.m250,
                              style: TextStyleFontTheme.luckiestGuy.copyWith(
                                  color: watch(setGameProvider).level == e
                                      ? Colors.black87
                                      : Colors.black45,
                                  fontSize: notifier.level == e ? 48 : 24),
                              child: FittedBox(child: Text(e.toUpperCase())),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ))
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CreateGameTitle(title: "Number of players"),
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Container(),
                  ),
                ),
                Flexible(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlayerAdjustButton(
                          icon: Icons.chevron_left,
                          arrowClick: notifier.playerCount == 2
                              ? null
                              : () => notifier.playerCount--,
                        ),
                        Flexible(
                          //flex: 2,
                          child: FractionallySizedBox(
                            //widthFactor: 1,
                            heightFactor: 1,
                            child: FittedBox(
                              child: AnimatedSwitcher(
                                duration: DurationCount.m250,
                                child: Text(
                                  "${setGame.playerCount}",
                                  key: ValueKey(setGame.playerCount),
                                  style:
                                      TextStyleFontTheme.luckiestGuy.copyWith(
                                    color: Colors.indigo[200],
                                  ),
                                  textScaleFactor: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        PlayerAdjustButton(
                          icon: Icons.chevron_right,
                          arrowClick: notifier.playerCount == 6
                              ? null
                              : () => notifier.playerCount++,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CreateGameTitle(title: "Game type"),
                Flexible(
                  flex: 2,
                  child: Row(
                    children: ["normal", "closed", "orderWise"]
                        .map(
                          (e) => Flexible(
                            child: TextButton(
                              onPressed: () => notifier.type = e,
                              child: AnimatedDefaultTextStyle(
                                duration: DurationCount.m250,
                                style: TextStyleFontTheme.luckiestGuy.copyWith(
                                    color: watch(setGameProvider).type == e
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontSize: notifier.type == e ? 48 : 24),
                                child: FittedBox(
                                  child: Text(
                                    e.toUpperCase(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: AnimatedSwitcher(
                      duration: DurationCount.m500,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation.drive(Tween(begin: 0, end: 1)),
                        child: SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0.25, 0.0),
                              end: const Offset(0.0, 0.0),
                            ),
                          ),
                          child: child,
                        ),
                      ),
                      child: Text(
                        setGame.details,
                        key: ValueKey(setGame.type),
                        style: TextStyleFontTheme.poppins,
                      ),
                    ),
                  ),
                )
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Choose Game Level',
                                style: TextStyleFontTheme.poppins,
                              ),
                              duration: DurationCount.m500,
                            ),
                          );
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
                      child: FittedBox(
                        child: Text(
                          "Start Game",
                          style: TextStyleFontTheme.luckiestGuy
                              .copyWith(color: Colors.white70, fontSize: 36),
                        ),
                      ),
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

class PlayerAdjustButton extends StatelessWidget {
  const PlayerAdjustButton(
      {Key? key, required this.arrowClick, required this.icon})
      : super(key: key);
  final IconData? icon;
  final VoidCallback? arrowClick;

  @override
  Widget build(BuildContext context) => Flexible(
        child: IconButton(
          constraints: BoxConstraints.expand(),
          icon: FittedBox(
            child: Icon(icon),
          ),
          color: Colors.white70,
          iconSize: 36,
          onPressed: arrowClick,
        ),
      );
}

class CreateGameTitle extends StatelessWidget {
  final String title;

  const CreateGameTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: AutoSizeText(
          title,
          style: TextStyleFontTheme.luckiestGuy
              .copyWith(color: Colors.white54, wordSpacing: 2),
          textScaleFactor: 2,
        ),
      );
}
