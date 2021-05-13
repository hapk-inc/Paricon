import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/pageProvider.dart';
import 'package:paricon/providers/roomNotifierProvider.dart';
import 'package:paricon/providers/roomProvider.dart';
import 'package:paricon/providers/setGameProvider.dart';

import 'gameRoom.dart';

class SetGame extends StatelessWidget {
  final bool isGameOnline;

  const SetGame({Key key, this.isGameOnline = false}) : super(key: key);
  static MaterialPage get toMaterialPage => MaterialPage(
      child: SetGame(), key: ValueKey('setGame'), name: '/setGame');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Consumer(
            builder: (context, watch, child) {
              final setGame = watch(setGameProvider);
              return Column(
                children: [
                  Spacer(),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set Game Level",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: Colors.indigo[200],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const ["Easy", "Medium", "Hard"]
                          .map(
                            (level) => ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        setGame.level != level
                                            ? Colors.indigo[200]
                                            : Colors.indigo[700]),
                                elevation: MaterialStateProperty.all(8.0),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              onPressed: () => setGame.level = level,
                              child: FittedBox(
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: setGame.level != level
                                        ? Colors.indigo[900]
                                        : Colors.white70,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set Number of Players",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: Colors.indigo[200],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: Colors.indigo[200],
                                size: 40,
                              ),
                              splashRadius: 16,
                              onPressed: setGame.playerCount == 1
                                  ? null
                                  : () => setGame.playerCount--,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                "${setGame.playerCount}",
                                key: ValueKey(setGame.playerCount),
                                style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.indigo[200],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: Colors.indigo[200],
                                size: 40,
                              ),
                              onPressed: setGame.playerCount == 6
                                  ? null
                                  : () => setGame.playerCount++,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SetGameButton(),
                  Spacer(),
                  Flexible(
                    child: Consumer(
                      builder: (context, watch, child) => AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: watch(roomNotifierProvider).loading ? 1 : 0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SetGameButton extends StatelessWidget {
  const SetGameButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          alignment: Alignment.centerRight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white54),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () async {
                context.read(roomNotifierProvider).loading = true;
                await context.read(createRoomProvider.future).then(
                  (value) async {
                    if (value != null) {
                      await context.read(joinRoomProvider.future);
                      context
                          .read(pageProvider)
                          .addNext(GameRoom.toMaterialPage(id: value));
                    }
                  },
                ).whenComplete(
                    () => context.read(roomNotifierProvider).loading = false);
              },
              child: Text(
                "SET GAME",
                style: TextStyle(
                  color: Colors.indigo[900],
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  letterSpacing: 5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
