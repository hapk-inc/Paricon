import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/providers/authProvider.dart';
import 'package:paricon/screens/providers/playerProvider.dart';
import 'package:paricon/screens/providers/practiceProvider.dart';
import 'package:paricon/screens/providers/roomIDProvider.dart';
import 'package:paricon/screens/providers/roomProvider.dart';

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
            Text("Really ${context.read(firebaseUserProvider!).displayName}.."),
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
                  context.read(practiceProvider).dispose();
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
                  await context.refresh(profileProvider!);
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
