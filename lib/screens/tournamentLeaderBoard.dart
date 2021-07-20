import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/tournament.dart';

import 'common/buttonStyleTheme.dart';
import 'common/durationCount.dart';
import 'common/textTheme.dart';
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
                  timeValid(_time) || kDebugMode ? LeaderBoard() : EndGame(),
            ),
          ),
        ),
      );

  bool timeValid(TimeOfDay _time, {int start = 9, int end = 21}) {
    return TimeOfDay(hour: start, minute: 0).doubleConversion <
            _time.doubleConversion &&
        _time.doubleConversion <
            TimeOfDay(hour: end, minute: 0).doubleConversion;
  }
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
                    data: (available) =>
                        !available ? beTheFirstPlayer() : ParticipantsList(),
                    loading: () => beTheFirstPlayer(),
                    error: (error, stackTrace) => Container(),
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
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "Ends at 9:00 PM",
                            style: TextStyleFontTheme.luckiestGuy
                                .copyWith(fontSize: 24, color: Colors.white60),
                          ),
                        ),
                      ),
                      TournamentStartButton()
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: Text(
                          "ALL TIME RECORD",
                          style: TextStyleFontTheme.poppins.copyWith(
                              fontSize: 16,
                              color: Colors.white60,
                              letterSpacing: 3),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: ListTile(
                          title: Text(
                            "23.34",
                            style: TextStyleFontTheme.luckiestGuy
                                .copyWith(fontSize: 48, color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: FittedBox(
                            child: AutoSizeText.rich(
                              TextSpan(
                                text: "By ",
                                children: [
                                  TextSpan(
                                    text: "Lenin Castro",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  TextSpan(text: " (122123)")
                                ],
                                style: TextStyleFontTheme.poppins,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class ParticipantsList extends StatelessWidget {
  const ParticipantsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FirebaseAnimatedList(
        query: context.read(participantsQueryProvider!),
        itemBuilder: (_, snapshot, animation, index) {
          final participant = Participant.fromMap(snapshot.value);
          return FadeTransition(
            opacity: animation,
            child: AnimatedSwitcher(
              duration: DurationCount.m500,
              child: SizedBox(
                key: ValueKey(participant),
                height: MediaQuery.of(context).size.height * 0.15,
                child: Card(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            isThreeLine: false,
                            title: AutoSizeText(
                              participant.name,
                              style: TextStyleFontTheme.luckiestGuy.copyWith(
                                fontSize: 36,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                            //horizontalTitleGap: 50,
                            subtitle: AutoSizeText(
                              "${participant.id}",
                              maxLines: 1,
                              style: TextStyleFontTheme.poppins.copyWith(
                                color: Colors.white54,
                                letterSpacing: 1,
                              ),
                            ),
                            trailing: AutoSizeText(
                              "${participant.gamesPlayed} Games",
                              style: TextStyleFontTheme.poppins.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                            ),
                            //horizontalTitleGap: 10,
                          ),
                          flex: 6,
                        ),
                        Flexible(
                          child: AutoSizeText.rich(
                            TextSpan(
                                children: participant.duration.inHoursMinutes
                                    .split('')
                                    .map(
                                      (e) => TextSpan(
                                        text: e,
                                        style: int.tryParse(e) != null
                                            ? TextStyleFontTheme.luckiestGuy
                                                .copyWith(
                                                fontSize: 40,
                                                color: Colors.white60,
                                              )
                                            : TextStyleFontTheme.luckiestGuy
                                                .copyWith(
                                                    fontSize: 24,
                                                    color: Colors.white54),
                                      ),
                                    )
                                    .toList(),
                                style: TextStyle(letterSpacing: 2)),
                            maxLines: 1,
                          ),
                          flex: 4,
                        ),
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
                  "Wait for Next Game to Start",
                  style: TextStyleFontTheme.poppins.copyWith(fontSize: 24),
                ),
              ),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.2,
                  child: Container(),
                ),
              ),
              Consumer(
                builder: (_, watch, __) => AnimatedSwitcher(
                    duration: DurationCount.m250,
                    child: watch(todayWinnerProvider).maybeWhen(
                      orElse: () => Container(),
                      data: (value) =>
                          value == null ? Container() : prevWinner(value),
                    )),
              )
            ],
          ),
        ),
      );

  RichText prevWinner(Participant p) => RichText(
        text: TextSpan(
          text: "In previous Game, ",
          style: TextStyleFontTheme.poppins.copyWith(fontSize: 16),
          children: [
            TextSpan(
              text: p.name,
              style: TextStyle(fontSize: 24),
            ),
            TextSpan(text: " (${p.id})\n"),
            TextSpan(text: "is the winner at "),
            TextSpan(
              text: p.duration.inHHMM,
              style: TextStyle(fontSize: 24),
            ),
            TextSpan(text: " minutes"),
          ],
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
            onPressed: () {
              if (context.read(checkTournamentTimeProvider))
                context
                    .read(pageProvider)
                    .replace(TournamentBoard.toMaterialPage);
              else
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Today's Tournament Over",
                      style: TextStyleFontTheme.poppins,
                    ),
                  ),
                );
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
