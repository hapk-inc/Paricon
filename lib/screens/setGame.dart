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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        child: Text(
                          "Set Game Level",
                          style: TextStyle(
                            fontSize: 96,
                            fontFamily: 'LuckiestGuy',
                            color: Colors.indigo[200],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const ["Easy", "Medium", "Hard"]
                          .map(
                            (level) => Flexible(
                              child: FractionallySizedBox(
                                widthFactor: 0.8,
                                heightFactor: 1,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            setGame.level != level
                                                ? Colors.indigo[200]
                                                : Colors.indigo[700]),
                                    elevation: MaterialStateProperty.all(8.0),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    /*padding: MaterialStateProperty.all(
                                        EdgeInsets.all(32.0)),*/
                                  ),
                                  onPressed: () => setGame.level = level,
                                  child: FractionallySizedBox(
                                    heightFactor: 0.6,
                                    child: FittedBox(
                                      child: Text(
                                        level,
                                        style: TextStyle(
                                          color: setGame.level != level
                                              ? Colors.indigo[900]
                                              : Colors.white70,
                                          fontSize: 96,
                                          //fontFamily: 'Poppins',
                                          letterSpacing: 5,
                                        ),
                                      ),
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
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        child: Text(
                          "Set Number of Players",
                          style: TextStyle(
                            fontSize: 96,
                            fontFamily: 'LuckiestGuy',
                            color: Colors.indigo[200],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Container(
                            alignment: Alignment.centerRight,
                            //color: Colors.yellow,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: OutlinedButton(
                              child: FittedBox(
                                child: Icon(
                                  Icons.chevron_left,
                                  size: 128,
                                  color: Colors.white70,
                                ),
                              ),
                              onPressed: setGame.playerCount == 2
                                  ? null
                                  : () => setGame.playerCount--,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  "${setGame.playerCount}",
                                  key: ValueKey(setGame.playerCount),
                                  style: TextStyle(
                                    fontSize: 128,
                                    color: Colors.indigo[200],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            //color: Colors.yellow,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: OutlinedButton(
                              child: FittedBox(
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 128,
                                  color: Colors.white70,
                                ),
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
  Widget build(BuildContext context) => Flexible(
        child: FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 0.9,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.indigo[600]),
              shadowColor: MaterialStateProperty.all<Color>(Colors.indigo[400]),
              elevation: MaterialStateProperty.all<double>(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FittedBox(
                child: Text(
                  "Start Game",
                  style: TextStyle(color: Colors.indigo[100], fontSize: 960),
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
          ),
        ),
      );
}
