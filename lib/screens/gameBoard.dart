import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';
import 'package:paricon/providers/authProvider.dart';
import 'package:paricon/providers/boardProvider.dart';
import 'package:paricon/providers/pageProvider.dart';
import 'package:paricon/providers/roomNotifierProvider.dart';
import 'package:paricon/providers/roomProvider.dart';

import 'results.dart';

class GameBoard extends StatelessWidget {
  static MaterialPage toMaterialPage() => MaterialPage(
        child: GameBoard(),
        name: '/gameBoard',
        key: ValueKey('gameBoard'),
      );
  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() async => await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.indigo[800],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            actionsPadding: const EdgeInsets.all(4.0),
            titleTextStyle: Theme.of(context).textTheme.bodyText1,
            contentTextStyle:
                Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
            title: const Text('Really..'),
            content: FittedBox(
              child: Text(
                'Leaving at middle of the game?',
              ),
            ),
            actions: const ["YES", "NO"]
                .map(
                  (title) => TextButton(
                    onPressed: () async {
                      /*if (title.contains("YES"))
                        await context.read(leavingBoardProvider.future);*/
                      Navigator.pop(ctx, title.contains("YES"));
                    },
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.white54,
                        fontSize: 16,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Consumer(
          builder: (ctx, watch, _) => ProviderListener<AsyncValue<int>>(
            provider: iconsFoundProvider,
            onChange: (context, stream) {
              stream.whenData(
                (value) async {
                  final board = await watch(boardProvider.future);
                  final num iconCount = board.icons.length;
                  //if (value % 2 == 0 && value > 8) {
                  if (value == iconCount) {
                    print("Game Over");
                    final isUpdated = await watch(updateStatsProvider.future);
                    if (isUpdated ?? false)
                      context
                          .read(pageProvider)
                          .replace(GameResults.toMaterialPage());
                  }
                },
              );
            },
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: watch(boardProvider).when(
                  data: (value) => Column(
                    children: [
                      PlayerName(),
                      GridIcons(value.icons),
                      ListPlayers(value.players),
                    ],
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text("Something happened \n $error \n $stackTrace"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ListPlayers extends StatelessWidget {
  final List players;
  const ListPlayers(this.players, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: players.map((player) => PlayerWdgt(player)).toList(),
        ),
      );
}

class PlayerWdgt extends StatelessWidget {
  final String playerID;
  const PlayerWdgt(this.playerID, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.8,
        child: Consumer(
          builder: (context, watch, child) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: watch(localPlayerProvider(playerID)).when(
              data: (_player) {
                bool _yourTurn = watch(currentIDProvider).maybeWhen(
                  orElse: () => false,
                  data: (value) => playerID == value,
                );
                return PlayerBox(yourTurn: _yourTurn, player: _player);
              },
              loading: () => Container(),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerBox extends StatelessWidget {
  const PlayerBox({Key key, @required this.yourTurn, @required this.player})
      : super(key: key);

  final bool yourTurn;
  final LocalPlayer player;

  @override
  Widget build(BuildContext context) => Card(
        elevation: yourTurn ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ClipPath(
          child: AnimatedContainer(
            decoration: BoxDecoration(
                color: yourTurn ? Colors.indigo : Colors.indigo[200],
                borderRadius: BorderRadius.circular(16.0)),
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        "${player.pts}",
                        key: ValueKey(player.pts),
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 48,
                          color: yourTurn ? Colors.indigo[200] : Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 24,
                        color: yourTurn ? Colors.indigo[200] : Colors.indigo,
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

class GridIcons extends StatelessWidget {
  final List icons;
  const GridIcons(this.icons, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 6,
        child: GridView.count(
          crossAxisCount: _crossAxisIconCount(icons.length),
          padding: const EdgeInsets.all(12.0),
          children: List.from(icons.map((icon) => IconWdgt(icon))),
        ),
      );

  int _crossAxisIconCount(int count) => count == 42
      ? 6
      : count == 72
          ? 8
          : 4;
}

class IconWdgt extends ConsumerWidget {
  final String id;
  const IconWdgt(this.id, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final localIcon = watch(iconProvider(id));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: localIcon.maybeWhen(
        orElse: () => Card(
          elevation: 12,
          color: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(),
        ),
        data: (_icon) {
          final bool checkFound = _icon.isCheck || _icon.isFound;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            transform: Matrix4.translationValues(-5, 5, 0)
              ..rotateZ((!checkFound
                      ? (Random.secure().nextBool() ? -pi : pi)
                      : -pi) /
                  (checkFound ? 60 : 15)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              //color: _icon.isFound ? Colors.white60 : Colors.indigo,
            ),
            child: ClipRRect(
              child: Card(
                elevation: 12,
                color: _icon.isFound ? Colors.white60 : Colors.indigo,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: checkFound
                      ? ShowIconWdgt(_icon.iconCode, _icon.isFound)
                      : ShowIconBtnWdgt(id, _icon.iconCode),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShowIconBtnWdgt extends ConsumerWidget {
  final String id;
  final int iconCode;
  const ShowIconBtnWdgt(this.id, this.iconCode, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final firebaseUser = watch(currentUserProvider);
    final roomNotifier = watch(roomNotifierProvider);
    bool _yourTurn = watch(currentIDProvider).maybeWhen(
      orElse: () => false,
      data: (value) {
        return firebaseUser.uid == value;
      },
    );
    return InkWell(
      onTap: _yourTurn && !roomNotifier.loading
          ? () async {
              IconInfo info = IconInfo(id, iconCode);
              roomNotifier.loading = true;
              await watch(btnClickProvider(info).future).whenComplete(
                () => roomNotifier.loading = false,
              );
            }
          : null,
    );
  }
}

class ShowIconWdgt extends ConsumerWidget {
  final int iconCode;

  final bool isFound;
  const ShowIconWdgt(this.iconCode, this.isFound, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final double paddingValue = watch(roomProvider).maybeWhen(
      orElse: () => 12.0,
      data: (value) => isFound
          ? 4.0
          : value.details.level.toLowerCase() == "hard"
              ? 6.0
              : 8.0,
    );
    return Center(
      child: AnimatedContainer(
        padding: EdgeInsets.all(paddingValue),
        duration: const Duration(milliseconds: 500),
        color: isFound ? Colors.white10 : Colors.indigo,
        child: FittedBox(
          child: Icon(
            IconData(iconCode, fontFamily: 'MaterialIcons'),
            color: isFound ? Colors.indigo : Colors.white70,
            size: 64,
          ),
        ),
      ),
    );
  }
}

class PlayerName extends StatelessWidget {
  const PlayerName({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.bottomLeft,
          child: Consumer(
            builder: (_, watch, child) {
              final firebaseUser = watch(firebaseUserProvider);
              bool _yourTurn = watch(currentIDProvider).maybeWhen(
                orElse: () => false,
                data: (value) => firebaseUser.uid == value,
              );
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _yourTurn
                    ? PlayerNameWidget(
                        value: "Your Turn",
                      )
                    : watch(nameProvider).when(
                        data: (value) => PlayerNameWidget(value: value),
                        loading: () => PlayerNameWidget(value: "loading")),
              );
            },
          ),
        ),
      );
}

class PlayerNameWidget extends StatelessWidget {
  final String value;
  const PlayerNameWidget({Key key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      key: ValueKey(value),
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .copyWith(fontSize: 32, color: Colors.indigo),
    );
  }
}
