import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/providers/authProvider.dart';
import 'package:paricon/screens/providers/roomIDProvider.dart';

import 'paddingTheme.dart';
import 'textTheme.dart';

class ExitPopup extends StatelessWidget {
  const ExitPopup({Key key}) : super(key: key);

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
            Text("Really ${context.read(firebaseUserProvider).displayName}.."),
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
                  if (e.contains("yes"))
                    context.read(idNotifier.notifier).empty();
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
