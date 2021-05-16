import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/profile.dart';
import 'package:paricon/providers/authProvider.dart';
import 'package:paricon/providers/pageProvider.dart';
import 'package:paricon/providers/playerProvider.dart';
import 'package:paricon/providers/roomIDProvider.dart';
import 'package:paricon/providers/roomProvider.dart';

import 'gameBoard.dart';

class GameRoom extends StatelessWidget {
  static MaterialPage toMaterialPage({String id}) => MaterialPage(
        child: GameRoom(),
        name: '/gameRoom',
        key: ValueKey('gameRoom'),
        arguments: id,
      );

  const GameRoom({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() async => await showDialog(
          context: context,
          builder: (_) => CloseRoomPopUp(),
        );

    return Scaffold(
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SafeArea(
          child: Column(
            children: [
              RoomDetailsWidget(),
              PlayersWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomDetailsWidget extends StatelessWidget {
  const RoomDetailsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
          ),
        ),
        child: Consumer(
          builder: (context, watch, child) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: watch(roomProvider).when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              data: (value) {
                final _room = value.details;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CreatorWidget(),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RoomCodeWidget(roomCode: _room.roomCode),
                          CreatorButton(),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _room.level.toUpperCase(),
                          "MAX PLAYERS: ${_room.maxCount}"
                        ].map((e) => RoomDetailsTxtWidget(e)).toList(),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CreatorWidget extends ConsumerWidget {
  const CreatorWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) => Flexible(
        child: FractionallySizedBox(
          heightFactor: 0.6,
          //padding: const EdgeInsets.all(32.0),
          child: FittedBox(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: watch(creatorIDProvider).maybeWhen(
                orElse: () => CreatorTitleWidget(name: "_"),
                data: (value) {
                  final firebaseUser = watch(firebaseUserProvider);
                  return firebaseUser.uid == value
                      ? CreatorTitleWidget(name: "You")
                      : watch(creatorNameProvider(value)).maybeWhen(
                          orElse: () => CreatorTitleWidget(name: "Someone"),
                          data: (_name) => CreatorTitleWidget(name: _name),
                        );
                },
              ),
            ),
          ),
        ),
      );
}

class CreatorTitleWidget extends StatelessWidget {
  final String name;
  const CreatorTitleWidget({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      key: ValueKey(name),
      text: TextSpan(
        text: name,
        style: Theme.of(context)
            .textTheme
            .bodyText2
            .copyWith(fontSize: 128, letterSpacing: 2, color: Colors.white70),
        children: [
          TextSpan(
            text: " created this Room",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
                fontSize: 96,
                color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class RoomCodeWidget extends StatelessWidget {
  final int roomCode;
  const RoomCodeWidget({Key key, this.roomCode}) : super(key: key);
  @override
  Widget build(BuildContext context) => Flexible(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            child: Text(
              "$roomCode",
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontSize: 128,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[100],
                    letterSpacing: 10,
                  ),
            ),
          ),
        ),
      );
}

class PlayersWidget extends StatelessWidget {
  const PlayersWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 7,
      child: Consumer(
        builder: (ctx, watch, _) => FirebaseAnimatedList(
          query: watch(playersQueryProvider),
          itemBuilder: (_context, snapshot, animation, _) {
            final room = watch(roomProvider).data?.value;
            if (room == null) return Center(child: CircularProgressIndicator());
            final String roomLevel = room.details.level;
            final int maxCount =
                room.details.maxCount > 4 ? room.details.maxCount : 4;

            Profile init = Profile.fromMap(snapshot.value);
            AsyncValue<Profile> profile =
                watch(otherProfileProvider(snapshot.key));

            return FadeTransition(
              opacity: animation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: MediaQuery.of(context).size.height * 0.7 / maxCount,
                child: Card(
                  elevation: 4,
                  color: Colors.white70,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: profile.when(
                      data: (value) => PlayerTile(
                        profile: value,
                        level: roomLevel,
                      ),
                      loading: () => LoadingPlayerWidget(
                        name: init.name,
                      ),
                      error: (error, stackTrace) => CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class RoomDetailsTxtWidget extends StatelessWidget {
  final String details;
  const RoomDetailsTxtWidget(this.details, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.7,
          child: Card(
            elevation: 8,
            color: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                child: Text(
                  details,
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.brown,
                        fontSize: 96,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
}

class PlayerTile extends StatelessWidget {
  final Profile profile;
  final String level;

  const PlayerTile({Key key, this.profile, this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List levels = ['easy', 'medium', 'hard'];
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: FittedBox(
                    child: Text(profile.userID.toString(),
                        style: TextStyle(fontSize: 96, fontFamily: "Poppins")),
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      "${profile.name}",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 72),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          // if (player.playerStats == null)
          Flexible(
              flex: 4,
              child: Center(
                child:
                    profile.stats[levels.indexOf(level.toLowerCase())].played ==
                            0
                        ? FittedBox(
                            child: Text(
                              "Never Played".toUpperCase(),
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 96,
                                  letterSpacing: 10),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              StatsWidget(
                                  title: "GAMES",
                                  value: profile.stats[0].played),
                              StatsWidget(
                                  title: "WIN", value: profile.stats[0].win),
                              StatsWidget(
                                  title: "AVG.", value: profile.stats[0].avg),
                            ],
                          ),
              ))
        ],
      ),
    );
  }
}

class LoadingPlayerWidget extends StatelessWidget {
  final String name;

  const LoadingPlayerWidget({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name + " entered the room",
        style: TextStyle(fontFamily: "Poppins"),
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  final String title;
  final num value;
  const StatsWidget({Key key, this.title, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: FittedBox(
                child: Text(
                  "$value",
                  style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
                ),
              ),
            ),
            Flexible(
              child: Center(
                child: FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class CreatorButton extends ConsumerWidget {
  const CreatorButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    SnackBar addOnePlayer() => const SnackBar(
          content: FittedBox(
            child: Text(
              'Add one more player to start Game',
              //style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        );
    final firebaseUser = watch(currentUserProvider);
    final bool _isCreatorIsYou = watch(creatorIDProvider).maybeWhen(
      orElse: () => false,
      data: (value) {
        return firebaseUser.uid == value;
      },
    );
    return Flexible(
      child: ProviderListener(
        provider: sGameStartProvider,
        onChange: (BuildContext context, AsyncValue<bool> asyncValue) {
          asyncValue.whenData(
            (_check) {
              if (_check)
                watch(pageProvider).replace(GameBoard.toMaterialPage());
            },
          );
        },
        child: FractionallySizedBox(
          heightFactor: 0.8,
          widthFactor: 0.8,
          child: ElevatedButton(
            onPressed: _isCreatorIsYou
                ? () => context
                        .read(createBoardProvider.future)
                        .then(
                          (_) => context.read(gameStartProvider),
                        )
                        .catchError(
                      (err, stackTrace) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(addOnePlayer());
                      },
                    )
                : null,
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.brown[600]),
                elevation:
                    MaterialStateProperty.all<double>(_isCreatorIsYou ? 16 : 4),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                shadowColor: MaterialStateProperty.all(Colors.brown[200])),
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: FittedBox(
                child: Text(
                  "START",
                  style: TextStyle(
                    color: _isCreatorIsYou ? Colors.white70 : Colors.white30,
                    fontSize: 96,
                    //fontWeight: FontWeight.bold,
                    letterSpacing: 5,
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

class CloseRoomPopUp extends StatelessWidget {
  const CloseRoomPopUp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.brown[400],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        actionsPadding: const EdgeInsets.all(4.0),
        title: Text(
          'Really..',
          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 24),
        ),
        content: FittedBox(
          child: Text(
            'Do you wish to leave now?',
            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
          ),
        ),
        actions: const ["YES", "NO"]
            .map(
              (title) => TextButton(
                onPressed: () async {
                  if (title.contains("YES"))
                    context.read(idNotifier.notifier).empty();
                  Navigator.pop(context, title.contains("YES"));
                },
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.white54,
                        fontSize: 16,
                        letterSpacing: 5,
                      ),
                ),
              ),
            )
            .toList(),
      );
}
