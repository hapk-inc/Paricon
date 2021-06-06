import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/buttonStyleTheme.dart';
import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/textTheme.dart';
import 'practiceGame.dart';
import 'providers/gameIconProvider.dart';
import 'providers/pageProvider.dart';
import 'providers/practiceProvider.dart';

class SetPractice extends ConsumerWidget {
  const SetPractice({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: SetPractice(),
        key: ValueKey('setPractice'),
        name: '/setPractice',
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final practice = watch(practiceProvider);
    return Scaffold(
      backgroundColor: Colors.red[200],
      body: SafeArea(
        child: Container(
          padding: PaddingTheme.all8,
          child: Column(
            children: [
              Flexible(
                child: Container(
                  padding: PaddingTheme.all4,
                  constraints: BoxConstraints.expand(),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "Practice your game",
                      style: TextStyleFontTheme.luckiestGuy,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  padding: PaddingTheme.all16,
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ["easy", "medium", "hard"]
                          .map(
                            (e) => TextButton(
                              onPressed: () => practice.level = e,
                              child: AnimatedDefaultTextStyle(
                                duration: DurationCount.m250,
                                style: TextStyleFontTheme.luckiestGuy.copyWith(
                                    color: practice.level == e
                                        ? Colors.black87
                                        : Colors.black45,
                                    fontSize: practice.level == e ? 48 : 24),
                                child: FittedBox(child: Text(e.toUpperCase())),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.blue,
                indent: 16,
                endIndent: 16,
                thickness: 2.5,
              ),
              Flexible(
                flex: 2,
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints.expand(),
                        child: FittedBox(
                          child: Checkbox(
                            value: practice.recordTime,
                            onChanged: (value) {
                              practice.recordTime = !practice.recordTime;
                            },
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Container(
                        padding: PaddingTheme.all8,
                        constraints: BoxConstraints.expand(),
                        child: FittedBox(
                          child: Text(
                            "Record your own game",
                            style: TextStyleFontTheme.luckiestGuy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "OR",
                    style: TextStyleFontTheme.poppins.copyWith(
                      color: Colors.indigo,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: PaddingTheme.all8,
                  alignment: Alignment.bottomLeft,
                  constraints: BoxConstraints.expand(),
                  child: FittedBox(
                    child: AutoSizeText(
                      "Play with your friends in one phone",
                      minFontSize: 24,
                      maxFontSize: 36,
                      style: TextStyleFontTheme.poppins
                          .copyWith(color: Colors.black87),
                      //maxLines: 2,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                //fit: FlexFit.tight,
                child: Container(
                  padding: PaddingTheme.all16,
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Row(
                      children: List.generate(
                        5,
                        (index) {
                          final int count = index + 2;
                          return TextButton(
                            onPressed: () => practice.playerCount = count,
                            child: AnimatedDefaultTextStyle(
                              duration: DurationCount.m250,
                              style: TextStyleFontTheme.luckiestGuy.copyWith(
                                  color: practice.playerCount == count
                                      ? Colors.black87
                                      : Colors.black45,
                                  fontSize:
                                      practice.playerCount == count ? 72 : 24),
                              child: FittedBox(
                                child: Text(
                                  count.toString(),
                                ),
                              ),
                            ),
                          );
                        },
                        growable: false,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      final xIcons = watch(gameIconProvider!);
                      practice.icons = xIcons.generateIcons(practice.level);
                      practice.createBoard();
                      context
                          .read(pageProvider)
                          .replace(PracticeBoard.toMaterialPage);
                    },
                    style: ButtonStyleTheme.buildDashboardButtonStyle(
                      btnColor: Colors.black54,
                    ).copyWith(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        "Start".toUpperCase(),
                        style: TextStyleFontTheme.poppins.copyWith(
                          color: Colors.white70,
                          fontSize: 48,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
