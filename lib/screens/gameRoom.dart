import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/profile.dart';
import '/models/roomDetails.dart';
import 'common/snackBarTheme.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'common/statsValue.dart';
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

  static List<Widget> get roomWidgetList => [DetailsWidget(), PlayersWidget()];

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
                child: FittedBox(
                  child: Text(
                    "Start",
                    style: TextStyleFontTheme.poppins.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                backgroundColor: Colors.brown,
                onPressed: () => context.read(createBoardProvider.future).then(
                  (created) {
                    if (created)
                      return context.read(gameStartProvider);
                    else
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBarThemeStyle.waitForOthers());
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

class PlayersWidget extends ConsumerWidget {
  const PlayersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) => Flexible(
        flex: 7,
        child: FirebaseAnimatedList(
          query: watch(playersQueryProvider!),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            final room = watch(roomProvider).data?.value;
            final List levels = ['easy', 'medium', 'hard'];
            if (room == null) return Center(child: CircularProgressIndicator());
            final String? roomLevel = room.details.level;
            final int maxCount =
                room.details.maxCount > 4 ? room.details.maxCount : 4;

            Profile init = Profile.onlyName(snapshot.value);
            AsyncValue<Profile> profile =
                watch(otherProfileProvider!(snapshot.key!));
            return FadeTransition(
              opacity: animation,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7 / maxCount,
                child: Card(
                  elevation: 4,
                  color: Colors.brown[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AnimatedSwitcher(
                    duration: DurationCount.m500,
                    child: profile.when(
                      data: (value) {
                        final stats = value
                            .stats![levels.indexOf(roomLevel!.toLowerCase())];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: FittedBox(
                                        child: Text(
                                          value.name,
                                          style: TextStyleFontTheme.luckiestGuy
                                              .copyWith(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.7 *
                                                          0.1,
                                                  color: Colors.brown),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        child: Text(
                                          value.userID.toString(),
                                          style: TextStyleFontTheme.poppins
                                              .copyWith(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.7 *
                                                          0.05,
                                                  color: Colors.brown[400]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 6,
                                child: stats.played == 0
                                    ? NeverPlayedWidget()
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            StatsValue(
                                                value: stats.played,
                                                header: "GAMES"),
                                            StatsValue(
                                                value: stats.win,
                                                header: "WINS"),
                                            StatsValue(
                                                value: stats.avg,
                                                header: "AVG. SCORE"),
                                          ],
                                        ),
                                      ),
                              )
                            ],
                          ),
                        );
                      },
                      loading: () => ListTile(title: Text(init.name)),
                      error: (error, stackTrace) {
                        error.toString();
                        stackTrace.toString();
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class NeverPlayedWidget extends StatelessWidget {
  const NeverPlayedWidget({Key? key}) : super(key: key);

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
