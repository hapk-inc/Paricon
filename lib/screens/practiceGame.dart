import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/screens/providers/pageProvider.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'common/textTheme.dart';
import 'gameBoard.dart';
import 'providers/authProvider.dart';
import 'providers/gameIconProvider.dart';
import 'providers/practiceProvider.dart';

class PracticeBoard extends ConsumerWidget {
  const PracticeBoard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: PracticeBoard(),
        key: ValueKey('practiceBoard'),
        name: '/practiceBoard',
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final practice = watch(practiceProvider);

    Future<bool> _onBackPressed() async => await showDialog(
          context: context,
          builder: (context) => ExitPractice(),
        );
    late String? prevRecord;
    if (practice.recordTime) {
      prevRecord = watch(prevTimeRecordProvider(practice.level)).maybeWhen(
        data: (value) => value!.isEmpty ? "" : value,
        orElse: () => "",
      );
    }
    return Scaffold(
      backgroundColor: Colors.white70,
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SafeArea(
          child: ProviderListener(
            provider: practiceProvider,
            onChange: (BuildContext context, PracticeNotifier notifier) {
              if (notifier.gameOver) {
                context
                    .read(pageProvider)
                    .replace(PracticeResult.toMaterialPage);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PracticePlayerName(),
                  Flexible(
                    flex: 7,
                    child: Center(
                      child: GridView.count(
                        padding: PaddingTheme.all8,
                        crossAxisCount: context
                            .read(gameIconProvider!)
                            .crossAxisCount(practice.icons.length),
                        shrinkWrap: true,
                        //childAspectRatio: newRatio,
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 2.0,
                        children: practice.icons
                            .map(
                              (_icon) => PracticeIconCard(
                                icon: _icon,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: practice.recordTime
                        ? FittedBox(
                            child: AnimatedSwitcher(
                              duration: DurationCount.m500,
                              child: Text(
                                prevRecord!.isEmpty
                                    ? "Play your First Game and record it"
                                    : "Your Prec Revord is $prevRecord",
                                key: ValueKey(prevRecord),
                                style: TextStyleFontTheme.poppins.copyWith(
                                    fontSize: 24, color: Colors.black87),
                              ),
                            ),
                          )
                        : PracticePlayers(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      //backgroundColor: Colors.blue,
    );
  }
}

class PracticePlayers extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final practice = watch(practiceProvider);
    final currentID = practice.currentID;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(practice.players.length, (index) {
        final player = practice.players[index];
        return Flexible(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: AnimatedContainer(
              duration: DurationCount.m500,
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                color: watch(gameIconProvider!)
                    .iconBoxColor(player.color)!
                    .withOpacity(index == practice.currentID ? 1 : 0.25),
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Center(
                  child: AnimatedDefaultTextStyle(
                style: TextStyleFontTheme.luckiestGuy.copyWith(
                    fontSize: index == currentID ? 24 : 16,
                    color:
                        index == currentID ? Colors.white70 : Colors.black26),
                duration: DurationCount.m500,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: FittedBox(child: Text(player.name!))),
                      Flexible(
                          child:
                              FittedBox(child: Text(player.pts!.toString()))),
                    ],
                  ),
                ),
              )),
            ),
          ),
        );
      }),
    );
  }
}

class PracticePlayerName extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final practice = watch(practiceProvider);
    final currentID = practice.currentID;
    final String playerName = practice.recordTime
        ? context.read(firebaseUserProvider!).displayName!
        : practice.players[currentID].name!;
    return Flexible(
      child: Row(
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Card(
                color: Colors.white30,
                elevation: 4,
                child: FittedBox(
                  child: AnimatedSwitcher(
                    duration: DurationCount.m500,
                    child: OutlineBorderText(
                      strokeColor: Colors.white70,
                      strokeWidth: 5,
                      child: Text(
                        playerName,
                        key: ValueKey(playerName),
                        style: TextStyleFontTheme.luckiestGuy.copyWith(
                          fontSize: 48,
                          color: watch(gameIconProvider!)
                              .iconColor(practice.players[currentID].color),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (practice.recordTime)
            Flexible(
              child: Container(
                color: Colors.yellow,
                constraints: BoxConstraints.expand(),
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: DurationCount.m250,
                  child: AutoSizeText(
                    practice.currentDuration.inSeconds.toString(),
                    minFontSize: 72,
                    style: TextStyleFontTheme.luckiestGuy
                        .copyWith(color: Colors.indigo),
                    key: ValueKey(practice.currentDuration.inSeconds),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class PracticeIconCard extends ConsumerWidget {
  final LocalIcon icon;
  const PracticeIconCard({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final practice = context.read(practiceProvider);
    final gameIcnProvider = watch(gameIconProvider!);
    return AnimatedContainer(
      duration: DurationCount.m500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      transform: Matrix4.rotationZ(
          (!icon.checkFound() ? (Random.secure().nextBool() ? -pi : pi) : -pi) /
              (icon.checkFound() ? 60 : 15)),
      child: ClipRect(
        child: Card(
          elevation: 8,
          child: AnimatedSwitcher(
            duration: DurationCount.m500,
            child: icon.checkFound()
                ? AnimatedContainer(
                    duration: DurationCount.m500,
                    alignment: Alignment.center,
                    padding: PaddingTheme.all4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: (icon.isFound ?? false)
                          ? gameIcnProvider
                              .iconColor(icon.color)!
                              .withOpacity(0.25)
                          : Colors.blue,
                    ),
                    child: FittedBox(
                      child: Icon(
                        gameIcnProvider.gameIcon(icon.iconCode),
                        color: (icon.isFound ?? false)
                            ? gameIcnProvider.iconColor(icon.color)
                            : Colors.white70,
                        size: 72,
                      ),
                    ),
                  )
                : InkWell(
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(4.0)),
                    ),
                    onTap: !practice.boardLoading
                        ? () => practice.validateIcons(icon)
                        : null,
                  ),
          ),
        ),
      ),
    );
  }
}

class PracticeResult extends StatelessWidget {
  const PracticeResult({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: PracticeResult(),
        key: ValueKey('practiceResult'),
        name: '/practiceResult',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            context.read(practiceProvider).dispose();
            return true;
          },
          child: Container()),
      //backgroundColor: Colors.blue,
    );
  }
}
