import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:paricon/screens/providers/authProvider.dart';

import '/models/localPlayer.dart';
import '/screens/dashboard.dart';
import '/screens/providers/gameIconProvider.dart';
import '/screens/providers/pageProvider.dart';
import '/screens/providers/playerProvider.dart';
import '/screens/providers/practiceProvider.dart';
import '/screens/providers/roomIDProvider.dart';
import '/screens/providers/roomProvider.dart';
import '/screens/providers/tournamentProvider.dart';
import 'paddingTheme.dart';
import 'textTheme.dart';

class ExitPopup extends StatelessWidget {
  final bool? isScreenBoard;

  const ExitPopup({Key? key, this.isScreenBoard}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.indigo[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        actionsPadding: PaddingTheme.all4,
        titleTextStyle: TextStyleFontTheme.poppins
            .copyWith(color: Colors.white70, fontSize: 24),
        title:
            //Text("Really ${context.read(firebaseUserProvider!).displayName}?"),
            Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: RichText(
                text: TextSpan(
                  text: "Really  ",
                  children: [
                    TextSpan(
                      text: context.read(firebaseUserProvider!).displayName,
                      style: TextStyleFontTheme.luckiestGuy.copyWith(
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    )
                  ],
                  style: TextStyleFontTheme.poppins.copyWith(
                    fontSize: 16,
                  ),
                ),
                maxLines: 1,
              ),
            ),
            /*Flexible(
              child: Lottie.asset(
                'assets/lottie/leavingEmoji.json',
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height * 0.05,
              ),
            ),*/
          ],
        ),
        content: FractionallySizedBox(
            //constraints: BoxConstraints.expand(),
            heightFactor: 0.1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Leaving at middle of the Game?",
                style: TextStyleFontTheme.poppins.copyWith(fontSize: 20),
                maxLines: 2,
              ),
            )),
        actions: const ["yes", "no"]
            .map(
              (e) => TextButton(
                onPressed: () async {
                  if (e.contains("yes")) {
                    /* if (isScreenBoard!)
                      await context.read(leavingBoardProvider.future);
                    else
                      await context.read(leavingRoomProvider.future);*/
                    if (!isScreenBoard!) {
                      await context.read(leavingRoomProvider.future);
                    }

                    context.read(idNotifier.notifier).empty();
                    //  context.read(onlineBoardNotifier).dispose();
                  }
                  Navigator.pop(context, e.contains("yes"));
                },
                child: Text(
                  e.toUpperCase(),
                  style: TextStyleFontTheme.poppins
                      .copyWith(color: Colors.white54, fontSize: 16),
                ),
              ),
            )
            .toList(),
      );
}

class ExitPractice extends StatelessWidget {
  const ExitPractice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        actionsPadding: PaddingTheme.all4,
        titleTextStyle: TextStyleFontTheme.poppins
            .copyWith(color: Colors.white70, fontSize: 24),
        title: Text(
          "Exit Game",
          style: TextStyleFontTheme.poppins.copyWith(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        content: FractionallySizedBox(
            heightFactor: 0.1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Leaving at middle of the Game?",
                style: TextStyleFontTheme.poppins.copyWith(fontSize: 20),
                maxLines: 2,
              ),
            )),
        actions: const ["yes", "no"]
            .map(
              (e) => TextButton(
                onPressed: () async {
                  //context.read(practiceProvider).dispose();
                  Navigator.pop(context, e.contains("yes"));
                },
                child: Text(
                  e.toUpperCase(),
                  style: TextStyleFontTheme.poppins
                      .copyWith(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
            .toList(),
      );
}

class ExitTournament extends StatelessWidget {
  const ExitTournament({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      actionsPadding: PaddingTheme.all4,
      titleTextStyle: TextStyleFontTheme.poppins
          .copyWith(color: Colors.white70, fontSize: 24),
      title: Text(
        "Exit Game",
        style: TextStyleFontTheme.poppins.copyWith(
          color: Colors.white54,
          fontSize: 16,
        ),
      ),
      content: FractionallySizedBox(
          heightFactor: 0.1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Leaving at middle of the Game?",
              style: TextStyleFontTheme.poppins.copyWith(fontSize: 20),
              maxLines: 2,
            ),
          )),
      actions: const ["yes", "no"]
          .map(
            (e) => TextButton(
              onPressed: () async {
                //context.read(practiceProvider).dispose();
                if (e.contains("yes"))
                  context.read(tournamentNotifierProvider).stopTime();
                Navigator.pop(context, e.contains("yes"));
              },
              child: Text(
                e.toUpperCase(),
                style: TextStyleFontTheme.poppins
                    .copyWith(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }
}

class EditNamePopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      backgroundColor: Colors.pink[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      actionsPadding: PaddingTheme.all4,
      titleTextStyle: TextStyleFontTheme.poppins
          .copyWith(color: Colors.white70, fontSize: 24),
      title: Text(
        "EDIT NAME",
        style: TextStyleFontTheme.poppins.copyWith(
          color: Colors.white54,
          fontSize: 16,
        ),
      ),
      content: FractionallySizedBox(
        heightFactor: 0.25,
        child: Center(
          child: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: Colors.white12,
            keyboardType: TextInputType.name,
            style: TextStyleFontTheme.poppins.copyWith(
              fontSize: MediaQuery.of(context).size.height * 0.025,
            ),
            decoration: InputDecoration(
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              labelText: "Your new name is",
              labelStyle: TextStyleFontTheme.poppins.copyWith(
                fontSize: 20,
                color: Colors.white54,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Colors.white38,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: const ["update", "discard"]
          .map(
            (e) => TextButton(
              onPressed: () async {
                if (e.contains("update")) {
                  await context
                      .read(updateNameProvider!(controller.text).future);
                  await context.refresh(profileProvider);
                }
                Navigator.pop(context);
              },
              child: Text(
                e.toUpperCase(),
                style: TextStyleFontTheme.poppins
                    .copyWith(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
          .toList(),
    );
  }
}

class WinPopUp extends StatelessWidget {
  final List<LocalPlayer> winners;

  const WinPopUp({Key? key, required this.winners}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Colors.indigo[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        actionsPadding: PaddingTheme.all4,
        titleTextStyle: TextStyleFontTheme.luckiestGuy.copyWith(
          color: Colors.white70,
          fontSize: 24,
          letterSpacing: 2,
        ),
        title: Center(
          child: Text("Congratulations"),
        ),
        content: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            child: Column(
              children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: PaddingTheme.all16,
                    child: Lottie.asset(
                      'assets/lottie/trophy.json',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: PaddingTheme.all8,
                    constraints: BoxConstraints.expand(),
                    child: FittedBox(
                      child: Text(
                        strConversion(winners),
                        style:
                            TextStyleFontTheme.poppins.copyWith(fontSize: 24),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read(pageProvider).replaceAll(Dashboard.toMaterialPage);
            },
            child: Text(
              "Exit Game".toUpperCase(),
              style: TextStyleFontTheme.poppins.copyWith(
                fontSize: 16,
                color: Colors.white38,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final xIcons = context.read(gameIconProvider);
              final practice = context.read(practiceProvider);
              practice.createPracticeBoard(
                xIcons.generateIcons(practice.level),
              );
              Navigator.pop(context, true);
            },
            child: Text(
              "PLAY AGAIN",
              style: TextStyleFontTheme.poppins.copyWith(
                fontSize: 20,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      );

  String strConversion(List<LocalPlayer> winners) => winners.length == 1
      ? winners.first.name.toString()
      : winners.fold(
          "",
          (previousValue, element) => previousValue.isEmpty
              ? element.name.toString() + ", "
              : previousValue +
                  (element != winners.last
                      ? element.name.toString() + ", "
                      : "and ${element.name.toString()}"),
        );
}

class TournamentGameWinPopUp extends StatelessWidget {
  final bool newRecord;
  const TournamentGameWinPopUp({Key? key, required this.newRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final duration = context.read(tournamentNotifierProvider).duration;
    return AlertDialog(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      titleTextStyle: TextStyleFontTheme.luckiestGuy.copyWith(
        fontSize: 36,
        color: Colors.white70,
      ),
      title: RichText(
        text: TextSpan(
          text: "Yeah",
          children: [
            if (!newRecord)
              TextSpan(
                text: "..but",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                  letterSpacing: 0,
                ),
              )
          ],
          style: TextStyleFontTheme.luckiestGuy.copyWith(
            fontSize: 36,
            letterSpacing: 2,
          ),
        ),
        textAlign: TextAlign.center,
      ),
      content: FractionallySizedBox(
        heightFactor: 0.5,
        widthFactor: 1,
        child: Column(
          children: [
            Flexible(
              flex: 8,
              child: Lottie.asset(
                newRecord
                    ? 'assets/lottie/star-happy.json'
                    : 'assets/lottie/star-sad.json',
                fit: BoxFit.contain,
              ),
            ),
            Spacer(),
            Flexible(
              child: FittedBox(
                child: RichText(
                  text: newRecord
                      ? TextSpan(
                          text: "That's a new record",
                          style: TextStyleFontTheme.bangers.copyWith(
                            fontSize: 24,
                          ),
                        )
                      : TextSpan(
                          text: "doesn't beat your",
                          children: [
                            TextSpan(
                              text: " previous",
                              style: TextStyle(fontSize: 24),
                            ),
                            TextSpan(text: " score"),
                          ],
                          style: TextStyleFontTheme.poppins.copyWith(
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read(pageProvider).remove();
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white70),
            textStyle: MaterialStateProperty.all(
              TextStyleFontTheme.luckiestGuy.copyWith(fontSize: 24),
            ),
            elevation: MaterialStateProperty.all(12),
          ),
          child: Text("EXIT GAME"),
        )
      ],
    );
  }
}
