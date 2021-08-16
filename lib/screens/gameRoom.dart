import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/profile.dart';
import '/models/roomDetails.dart';
import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'common/snackBarTheme.dart';
import 'common/textTheme.dart';
import 'gameBoard.dart';
import 'providers/authProvider.dart';
import 'providers/pageProvider.dart';
import 'providers/playerProvider.dart';
import 'providers/roomProvider.dart';

class GameRoom extends ConsumerWidget {
  const GameRoom({Key? key}) : super(key: key);

  static MaterialPage toMaterialPage({String? id}) => MaterialPage(
        child: GameRoom(),
        name: '/gameRoom',
        key: ValueKey('gameRoom'),
        arguments: id,
      );

  static List<Widget> get roomWidgetList => [
        DetailsWidget(),
        // PlayersWidget(),
        RoomPlayers(),
      ];

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final firebaseUser = watch(firebaseUserProvider!);
    final bool _isCreatorIsYou = watch(creatorIDProvider!).maybeWhen(
      orElse: () => false,
      data: (value) {
        return firebaseUser.uid == value;
      },
    );

    Future<bool> _onBackPressed() async => await showDialog(
          context: context,
          builder: (context) => ExitPopup(
            isScreenBoard: false,
          ),
        );

    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: ProviderListener(
          provider: sGameStartProvider,
          onChange: (BuildContext context, AsyncValue<bool> asyncValue) {
            asyncValue.whenData(
              (_check) {
                if (_check)
                  context.read(pageProvider).replace(GameBoard.toMaterialPage);
              },
            );
          },
          child: SafeArea(
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(children: roomWidgetList)
                : Row(children: roomWidgetList),
          ),
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: DurationCount.m500,
        child: _isCreatorIsYou
            ? FloatingActionButton(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    "Go",
                    style: TextStyleFontTheme.luckiestGuy.copyWith(
                      color: Colors.white70,
                      fontSize: 32,
                    ),
                    maxLines: 1,
                  ),
                ),
                backgroundColor: Colors.brown,
                onPressed: () => context.read(createBoardProvider.future).then(
                  (created) {
                    if (created)
                      return context.read(gameStartProvider);
                    else
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBarThemeStyle.waitForOthers);
                  },
                ),
                /*.catchError(
                  (err, stackTrace) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBarThemeStyle.waitForOthers());
                  },
                ),*/
              )
            : Container(),
      ),
    );
  }
}

class DetailsWidget extends ConsumerWidget {
  const DetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    List<Widget> detailList(RoomDetails details) =>
        [details.level, "${details.maxCount}P", details.type]
            .map(
              (_text) => Flexible(
                child: FittedBox(
                  child: AutoSizeText(
                    _text,
                    maxFontSize: 40,
                    minFontSize: 24,
                    style: TextStyleFontTheme.luckiestGuy.copyWith(
                      fontSize: 36,
                      color: Colors.brown[200],
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false);

    return Flexible(
      flex: 3,
      child: Card(
        elevation: 4,
        color: Colors.brown,
        child: Padding(
          padding: PaddingTheme.all8,
          //constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                  Point5SpaceWidget(),
                  CreatorWidget(),
                  Point5SpaceWidget(),
                ] +
                watch(roomProvider).when(
                  data: (room) => [
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        child: Text(
                          room.details.roomCode.toString(),
                          style: TextStyleFontTheme.luckiestGuy.copyWith(
                            fontSize: MediaQuery.of(context).size.height,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    Point5SpaceWidget(),
                    Flexible(
                      flex: 2,
                      child: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? Column(
                              children: <Widget>[Point5SpaceWidget()] +
                                  detailList(room.details),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: detailList(room.details),
                            ),
                    ),
                  ],
                  loading: () => [],
                  error: (error, stackTrace) => [],
                ),
          ),
        ),
      ),
    );
  }
}

class Point5SpaceWidget extends StatelessWidget {
  const Point5SpaceWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
      ),
    );
  }
}

class CreatorWidget extends ConsumerWidget {
  const CreatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) => Flexible(
        flex: 2,
        child: FittedBox(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: watch(creatorIDProvider!).maybeWhen(
              orElse: () => CreatorTitleWidget(name: "_"),
              data: (value) {
                final firebaseUser = watch(firebaseUserProvider!);
                return firebaseUser.uid == value
                    ? CreatorTitleWidget(name: "You ")
                    : watch(creatorNameProvider!(value)).maybeWhen(
                        orElse: () => CreatorTitleWidget(name: "Someone"),
                        data: (_name) => CreatorTitleWidget(name: _name),
                      );
              },
            ),
          ),
        ),
      );
}

class CreatorTitleWidget extends StatelessWidget {
  final String? name;

  const CreatorTitleWidget({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) => RichText(
        key: ValueKey(name),
        text: TextSpan(
          text: name ?? "Lo",
          style: TextStyleFontTheme.luckiestGuy.copyWith(
            letterSpacing: 2,
            color: Colors.white70,
            fontSize: MediaQuery.of(context).size.height,
          ),
          children: [
            TextSpan(
              text: name == null ? "_" : " created this Room",
              style: TextStyleFontTheme.poppins.copyWith(
                fontWeight: FontWeight.w100,
                color: Colors.white54,
                letterSpacing: 1,
                fontSize: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
          ],
        ),
      );
}

const List levels = ['easy', 'medium', 'hard'];

class RoomPlayers extends StatelessWidget {
  const RoomPlayers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 7,
        child: FirebaseAnimatedList(
          query: context.read(playersQueryProvider),
          itemBuilder:
              (_, DataSnapshot snapshot, Animation<double> animation, __) {
            final room = context.read(roomProvider).data!.value;
            final details = room.details;
            final String level = details.level;
            final int maxCount = details.maxCount > 4 ? details.maxCount : 4;

            final Profile init = Profile.onlyName(snapshot.value);
            /*final otherProfile =
                context.read(otherProfileProvider!(snapshot.key!)).data;*/
            final maxHeight =
                MediaQuery.of(context).size.height * 0.7 / maxCount;
            return FadeTransition(
              opacity: animation,
              child: SizedBox(
                height: maxHeight,
                child: Card(
                  elevation: 4,
                  color: Colors.brown[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Consumer(
                    builder: (_, watch, __) => AnimatedSwitcher(
                      duration: DurationCount.m500,
                      child: watch(otherProfileProvider!(snapshot.key!)).when(
                        data: (value) => PlayerTile(
                          level: level,
                          profile: value!,
                          key: ValueKey(value),
                        ),
                        loading: () => AutoSizeText(
                          "Welcome ${init.name}",
                          key: ValueKey(init),
                          style: TextStyleFontTheme.poppins
                              .copyWith(fontSize: 20, color: Colors.brown[800]),
                        ),
                        error: (error, stackTrace) => Container(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class PlayerTile extends StatelessWidget {
  final String level;
  final Profile profile;
  const PlayerTile({required this.level, required this.profile, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = profile.stats![levels.indexOf(level.toLowerCase())];

    return Container(
      padding: PaddingTheme.all8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 4,
            child: ListTile(
              title: AutoSizeText(
                profile.name,
                style: TextStyleFontTheme.luckiestGuy
                    .copyWith(color: Colors.brown, fontSize: 48),
                maxLines: 1,
              ),
              subtitle: AutoSizeText(
                "${profile.userID}",
                style: TextStyleFontTheme.poppins
                    .copyWith(color: Colors.brown[400]),
                maxLines: 1,
              ),
            ),
          ),
          Flexible(
            flex: 6,
            child: stats.played == 0
                ? NeverPlayed()
                : Container(
                    padding: PaddingTheme.all8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfileStats(value: stats.played, header: "GAMES"),
                        ProfileStats(value: stats.win, header: "WINS"),
                        ProfileStats(value: stats.avg, header: "AVG. SCORE"),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  final dynamic value;
  final String header;
  const ProfileStats({Key? key, required this.value, required this.header})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: ListTile(
          title: AutoSizeText(
            value.toString(),
            style: TextStyleFontTheme.luckiestGuy
                .copyWith(color: Colors.brown, fontSize: 24),
            maxLines: 1,
          ),
          subtitle: AutoSizeText(
            header,
            style:
                TextStyleFontTheme.poppins.copyWith(color: Colors.brown[400]),
            maxLines: 1,
          ),
        ),
      );
}

class NeverPlayed extends StatelessWidget {
  const NeverPlayed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: FittedBox(
          child: Text(
            "Never played yet",
            style: TextStyleFontTheme.luckiestGuy.copyWith(
                color: Colors.brown[400],
                fontSize: MediaQuery.of(context).size.height * 0.025
                //letterSpacing: 1.5,
                ),
          ),
        ),
      );
}
