import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/tournament.dart';
import 'package:paricon/screens/common/textTheme.dart';

import '/models/localIcon.dart';
import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'providers/gameIconProvider.dart';
import 'providers/playerProvider.dart';
import 'providers/tournamentProvider.dart';

class TournamentBoard extends StatelessWidget {
  const TournamentBoard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: TournamentBoard(),
        key: ValueKey('tournamentBoard'),
        name: '/tournamentBoard',
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: WillPopScope(
          onWillPop: () async => await showDialog(
            context: context,
            builder: (context) => ExitTournament(),
          ),
          child: SafeArea(
            child: ProviderListener(
              provider: tournamentNotifierProvider,
              onChange: (_, TournamentNotifier notifier) async {
                if (notifier.isGameOver) {
                  bool _newScore = false;
                  late Participant participant;
                  final me = context.read(myParticipantProvider).data!.value;

                  if (me == null) {
                    _newScore = true;
                    final pro = await context.read(profileProvider!.future);
                    participant = Participant(
                      name: pro.name,
                      id: "${pro.userID}",
                      duration: notifier.timeDoubleConversion,
                    );
                  } else {
                    _newScore = me.duration > notifier.timeDoubleConversion;
                    participant = me.copyWith(
                      duration: _newScore
                          ? notifier.timeDoubleConversion
                          : me.duration,
                      gamesPlayed: me.gamesPlayed + 1,
                    );
                    //print(participant.gamesPlayed);
                  }
                  await context
                      .read(updateParticipantProvider(participant).future);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => TournamentGameWinPopUp(
                      newRecord: _newScore,
                    ),
                  );
                }
              },
              child: Padding(
                padding: PaddingTheme.all4,
                child: Card(
                  color: Colors.white60,
                  elevation: 8,
                  child: Column(
                    children: [
                      TimerClock(),
                      Flexible(
                        flex: 5,
                        child: Consumer(
                          builder: (__, watch, _) {
                            final tournament =
                                watch(tournamentNotifierProvider);
                            return GridView.count(
                              crossAxisCount: 8,
                              padding: PaddingTheme.all8,
                              children: tournament.icons
                                  .map(
                                    (e) => LocalIconTournamentCard(
                                      icon: e,
                                      iconTap: () => !tournament.loading
                                          ? context
                                              .read(tournamentNotifierProvider)
                                              .validateIcons(e.iconNo! - 1)
                                          : null,
                                    ),
                                  )
                                  .toList(growable: false),
                            );
                          },
                        ),
                      ),
                      ShowPrevScore(),
                      Spacer()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

const String _firstGame = "Play your First Game";
const String _prevScore = "Your Previous Score is ";

class ShowPrevScore extends StatelessWidget {
  const ShowPrevScore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        // flex: 2,
        child: Center(
          child: Consumer(
            builder: (_, watch, __) => AnimatedSwitcher(
              duration: DurationCount.m250,
              child: watch(myParticipantProvider).when(
                data: (value) => RichText(
                  text: TextSpan(
                      children: [
                        if (value == null)
                          TextSpan(text: _firstGame)
                        else
                          TextSpan(
                            text: _prevScore,
                            children: [
                              TextSpan(
                                text: value.duration.inMinutes.toString(),
                                children: [
                                  TextSpan(
                                    text: " min ",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  TextSpan(
                                    text: "${value.duration.inSeconds}",
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
                          )
                      ],
                      style: TextStyleFontTheme.poppins
                          .copyWith(color: Colors.black54)),
                ),
                loading: () => Container(),
                error: (error, stackTrace) => Container(),
              ),
            ),
          ),
        ),
      );
}

class TimerClock extends StatelessWidget {
  const TimerClock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Consumer(
          builder: (_, watch, __) {
            final duration = watch(tournamentNotifierProvider).duration;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}"
                      .split("")
                      .map(
                        (e) => e.contains(":")
                            ? SizedBox(
                                width: 20,
                                child: Center(
                                  child: Text(
                                    ":",
                                    style: TextStyleFontTheme.luckiestGuy
                                        .copyWith(fontSize: 24),
                                  ),
                                ),
                              )
                            : AnimatedSwitcher(
                                duration: DurationCount.m250,
                                child: Text(
                                  e,
                                  key: ValueKey(e),
                                  style: TextStyleFontTheme.luckiestGuy
                                      .copyWith(fontSize: 48),
                                ),
                              ),
                      )
                      .toList(),
            );
          },
        ),
      );
}

class LocalIconTournamentCard extends StatelessWidget {
  final LocalIcon icon;
  final VoidCallback? iconTap;

  const LocalIconTournamentCard({
    Key? key,
    required this.icon,
    required this.iconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: DurationCount.m500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
        ),
        transform: Matrix4.rotationZ(
          (!icon.checkFound() ? (Random.secure().nextBool() ? -pi : pi) : -pi) /
              (icon.checkFound() ? 60 : 15),
        ),
        child: ClipRRect(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: AnimatedContainer(
              duration: DurationCount.m500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: icon.isFound ? Colors.white70 : Colors.blueGrey,
              ),
              child: AnimatedSwitcher(
                duration: DurationCount.m500,
                child: !icon.checkFound()
                    ? InkWell(onTap: iconTap)
                    : icon.isFound
                        ? TournamentFoundIcon(icon: icon)
                        : TournamentCheckIcon(iconCode: icon.iconCode),
              ),
            ),
          ),
        ),
      );
}

class TournamentFoundIcon extends StatelessWidget {
  final LocalIcon icon;

  const TournamentFoundIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameIcon = context.read(gameIconProvider);
    return Container(
      color: Colors.white70,
      constraints: BoxConstraints.expand(),
      padding: PaddingTheme.all4,
      child: Center(
        child: FittedBox(
          child: Icon(
            gameIcon.tournamentGameIcons(icon.iconCode),
            color: gameIcon.iconColor(icon.color),
            size: 72,
          ),
        ),
      ),
    );
  }
}

class TournamentCheckIcon extends StatelessWidget {
  final String iconCode;

  const TournamentCheckIcon({Key? key, required this.iconCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameIcon = context.read(gameIconProvider);

    return Container(
      padding: PaddingTheme.all4,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: FittedBox(
          child: Icon(
            gameIcon.tournamentGameIcons(iconCode),
            color: Colors.white70,
            size: 72,
          ),
        ),
      ),
    );
  }
}
