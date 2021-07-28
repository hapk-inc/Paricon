import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '/models/tournament.dart';
import 'common/buttonStyleTheme.dart';
import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/textTheme.dart';
import 'providers/authProvider.dart';
import 'providers/pageProvider.dart';
import 'providers/tournamentProvider.dart';
import 'tournamentGameBoard.dart';

class TournamentLeaderBoard extends ConsumerWidget {
  const TournamentLeaderBoard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: TournamentLeaderBoard(),
        key: ValueKey('tournamentLeaderBoard'),
        name: '/tournamentLeaderBoard',
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) => Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: DurationCount.m500,
            child: watch(liveTimeProvider).maybeWhen(
              orElse: () => Center(child: CircularProgressIndicator()),
              data: (_time) =>
                  _time.validTime() || kDebugMode ? LeaderBoard() : EndGame(),
            ),
          ),
        ),
      );
}

class LeaderBoard extends StatelessWidget {
  const LeaderBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Consumer(
                builder: (_, watch, __) => AnimatedSwitcher(
                  duration: DurationCount.m500,
                  child: watch(participantsAvailableProvider).when(
                    data: (available) => !available
                        ? beTheFirstPlayer()
                        : ParticipantsList(
                            key: ValueKey("participantsList"),
                          ),
                    loading: () => beTheFirstPlayer(),
                    error: (error, stackTrace) => Container(
                      key: ValueKey("error"),
                    ),
                  ),
                ),
              ),
              flex: 8,
            ),
            LeaderBoardFooter()
          ],
        ),
      );

  Widget beTheFirstPlayer() => Container(
        key: ValueKey("beTheFirst"),
        child: Center(
          child: Text(
            "Be the first player to start the tournament",
            style: TextStyleFontTheme.poppins
                .copyWith(color: Colors.black54, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class LeaderBoardFooter extends StatelessWidget {
  const LeaderBoardFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 2,
        child: Card(
          elevation: 8,
          color: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        EndsAt9(),
                        Divider(
                          thickness: 1,
                          color: Colors.white60,
                        ),
                        TournamentStartButton(),
                      ],
                    ),
                  ),
                  /* Container(
                    width: 1,
                    height: double.maxFinite,
                    color: Colors.grey,
                  ),*/
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AllTimeRecordTitle(),
                        AllTimeRecord(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class AllTimeRecord extends StatelessWidget {
  const AllTimeRecord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 4,
      child: Consumer(
        builder: (__, watch, _) => AnimatedSwitcher(
          duration: DurationCount.m250,
          child: watch(allTimeRecordProvider).when(
            data: (value) {
              if (value == null)
                return Container(
                  child: Text(
                    "No records for now",
                    style: TextStyleFontTheme.poppins.copyWith(fontSize: 16),
                  ),
                );
              final duration = value.duration;
              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        //if (duration.inMinutes != 0)
                        TextSpan(
                          text: "${duration.inMinutes}" + " ",
                        ),
                        TextSpan(
                          text: "." + "${duration.inSeconds}".padLeft(2, '0'),
                        ),
                        //TextSpan(text: "sec"),
                        TextSpan(
                          text: "  " +
                              "${duration.inMilliSeconds}".padLeft(2, '0') +
                              " ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: " min",
                          style: TextStyleFontTheme.meriendaOne.copyWith(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Colors.white30),
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyleFontTheme.luckiestGuy.copyWith(
                        fontSize: 32,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                subtitle: FittedBox(
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "By "),
                        TextSpan(
                          text: value.name,
                          style: TextStyleFontTheme.luckiestGuy
                              .copyWith(fontSize: 20),
                        ),
                        TextSpan(
                            text: " (${value.id})",
                            style: TextStyle(fontStyle: FontStyle.italic))
                      ],
                      style: TextStyleFontTheme.poppins.copyWith(fontSize: 12),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              );
            },
            error: (error, stackTrace) {
              print(stackTrace);
              return Container();
            },
            loading: () => Container(),
          ),
        ),
      ),
    );
  }
}

class AllTimeRecordTitle extends StatelessWidget {
  const AllTimeRecordTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Text(
          "ALL TIME RECORD",
          style: TextStyleFontTheme.poppins.copyWith(
            fontSize: 16,
            color: Colors.white60,
            letterSpacing: 3,
          ),
        ),
      );
}

class EndsAt9 extends StatelessWidget {
  const EndsAt9({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: FittedBox(
          child: Text(
            "Ends at 9:00 PM",
            style: TextStyleFontTheme.luckiestGuy
                .copyWith(fontSize: 24, color: Colors.white60),
          ),
        ),
      );
}

class ParticipantsList extends StatelessWidget {
  const ParticipantsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FirebaseAnimatedList(
        query: context.read(participantsQueryProvider!),
        sort: (a, b) => Participant.fromMap(a.value)
            .duration
            .compareTo(Participant.fromMap(b.value).duration),
        itemBuilder: (_, snapshot, animation, index) {
          final id = snapshot.key;
          final firebaseUser = context.read(firebaseUserProvider!);

          final participant = Participant.fromMap(snapshot.value);

          /*if (firebaseUser.uid == id)
            context.read(meParticipantProvider.notifier).state = participant;*/
          return FadeTransition(
            opacity: animation,
            child: AnimatedSwitcher(
              duration: DurationCount.m500,
              child: SizedBox(
                key: ValueKey(participant),
                height: MediaQuery.of(context).size.height *
                    (index == 0 ? 0.2 : 0.15),
                child: Card(
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: PaddingTheme.all16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            isThreeLine: false,
                            title: AutoSizeText(
                              id == firebaseUser.uid ? "You" : participant.name,
                              style: TextStyleFontTheme.luckiestGuy.copyWith(
                                fontSize: 36,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                            //horizontalTitleGap: 50,
                            subtitle: firebaseUser.uid == id
                                ? AutoSizeText.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "as  ",
                                            style: TextStyleFontTheme.poppins),
                                        TextSpan(
                                            text: firebaseUser.displayName,
                                            style: TextStyleFontTheme
                                                .luckiestGuy
                                                .copyWith(
                                                    fontSize: 24,
                                                    color: Colors.white60))
                                      ],
                                    ),
                                  )
                                : AutoSizeText(
                                    "${participant.id}",
                                    maxLines: 1,
                                    style: TextStyleFontTheme.poppins.copyWith(
                                      color: Colors.white54,
                                      letterSpacing: 1,
                                    ),
                                  ),
                            trailing: AutoSizeText(
                              participant.gamesPlayed == 1
                                  ? "First Game"
                                  : "${participant.gamesPlayed} Games",
                              style: TextStyleFontTheme.poppins.copyWith(
                                color: Colors.white30,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          flex: 6,
                        ),
                        ParticipantDuration(duration: participant.duration),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class ParticipantDuration extends StatelessWidget {
  final double duration;
  const ParticipantDuration({Key? key, required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 4,
        child: AutoSizeText.rich(
          TextSpan(
            children: [
              //if (duration.inMinutes != 0)
              TextSpan(
                text: "${duration.inMinutes}" + " ",
              ),
              TextSpan(
                text: "." + "${duration.inSeconds}".padLeft(2, '0'),
              ),
              //TextSpan(text: "sec"),
              TextSpan(
                text: "  " + "${duration.inMilliSeconds}".padLeft(2, '0') + " ",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "min",
                style: TextStyleFontTheme.meriendaOne.copyWith(
                  fontSize: 12,
                  color: Colors.white30,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          maxLines: 1,
          style: TextStyleFontTheme.luckiestGuy.copyWith(
            fontSize: 32,
            color: Colors.white60,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
}

class EndGame extends StatelessWidget {
  const EndGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey("endGame"),
        color: Colors.blueGrey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Please wait for next game to begin",
                  style: TextStyleFontTheme.poppins.copyWith(fontSize: 16),
                ),
              ),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                  child: Container(),
                ),
              ),
              Flexible(
                flex: 2,
                child: Consumer(
                  builder: (_, watch, __) => AnimatedSwitcher(
                    duration: DurationCount.m250,
                    child: watch(todayParticipantProvider).maybeWhen(
                      orElse: () => Container(),
                      data: (value) => value == null
                          ? Lottie.asset(
                              'assets/lottie/waiting-pigeon.json',
                              fit: BoxFit.contain,
                            )
                          : prevWinner(value),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Flexible(
                child: Text(
                  "Starts at 9 am",
                  style: TextStyleFontTheme.bangers.copyWith(
                    color: Colors.white70,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
              )
            ],
          ),
        ),
      );

  RichText prevWinner(Participant p) => RichText(
        text: TextSpan(
          children: [
            TextSpan(text: "and Congratulations  "),
            TextSpan(
              text: p.name + " ",
              children: [
                TextSpan(
                  text: " ${p.id} \n",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                )
              ],
              style: TextStyleFontTheme.luckiestGuy.copyWith(
                fontSize: 24,
                letterSpacing: 1,
              ),
            ),
            TextSpan(text: "for the previous game "),
            TextSpan(text: "with a record\n"),
            TextSpan(
              text: p.duration.inMinutes.toString(),
              children: [
                TextSpan(
                  text: " minutes ",
                  style: TextStyle(fontSize: 14),
                ),
                TextSpan(
                  text: "${p.duration.inSeconds}",
                  style: TextStyle(fontSize: 24),
                ),
                TextSpan(
                  text: " seconds",
                  style: TextStyle(fontSize: 14),
                ),
              ],
              style: TextStyleFontTheme.luckiestGuy.copyWith(
                fontSize: 32,
                letterSpacing: 1,
              ),
            ),
          ],
          style: TextStyleFontTheme.poppins.copyWith(height: 2),
        ),
        textAlign: TextAlign.center,
      );
}

class TournamentStartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Flexible(
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.8,
          child: ElevatedButton(
            onPressed: () async {
              final Duration? duration =
                  await context.read(tournamentPlayedProvider.future);
              if (duration == null || kDebugMode)
                context
                    .read(pageProvider)
                    .replace(TournamentBoard.toMaterialPage);
              else {
                final int timeGap = context.read(timeGapProvider);
                if (duration.inMinutes > timeGap)
                  context
                      .read(pageProvider)
                      .replace(TournamentBoard.toMaterialPage);
                else {
                  Duration remainingD = Duration(minutes: timeGap) - duration;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Still " +
                            (remainingD.inMinutes == 0
                                ? "${remainingD.inSeconds} seconds "
                                : "${remainingD.inMinutes} minutes ${(remainingD.inSeconds) % 60} seconds") +
                            " to play next Game ",
                        style: TextStyleFontTheme.poppins,
                      ),
                    ),
                  );
                }
              }
            },
            style: ButtonStyleTheme.createGameButtonStyle(),
            child: Text(
              "Start",
              style: TextStyleFontTheme.luckiestGuy.copyWith(
                fontSize: 24,
              ),
            ),
          ),
        ),
      );
}
