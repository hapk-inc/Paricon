import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/screens/providers/practiceProvider.dart';
import 'package:paricon/screens/providers/setGameProvider.dart';

import 'durationCount.dart';
import 'textTheme.dart';

class PlayerAdjustButton extends StatelessWidget {
  const PlayerAdjustButton(
      {Key? key, required this.arrowClick, required this.icon})
      : super(key: key);
  final IconData? icon;
  final VoidCallback? arrowClick;

  @override
  Widget build(BuildContext context) => Flexible(
        child: IconButton(
          constraints: BoxConstraints.expand(),
          icon: FittedBox(
            child: Icon(icon),
          ),
          color: Colors.white70,
          iconSize: 36,
          onPressed: arrowClick,
        ),
      );
}

class SetGameTitle extends StatelessWidget {
  final String title;

  const SetGameTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: AutoSizeText(
          title,
          style: TextStyleFontTheme.luckiestGuy
              .copyWith(color: Colors.white54, wordSpacing: 2),
          textScaleFactor: 2,
        ),
      );
}

class LevelButtons extends StatelessWidget {
  final String selectedLevel;

  const LevelButtons({Key? key, required this.selectedLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Center(
          child: Row(
            children: const ["easy", "medium", "hard"]
                .map(
                  (_level) => TextButton(
                    onPressed: () =>
                        context.read(practiceProvider).level = _level,
                    child: AnimatedDefaultTextStyle(
                      duration: DurationCount.m250,
                      style: TextStyleFontTheme.luckiestGuy.copyWith(
                          color: selectedLevel == _level
                              ? Colors.black87
                              : Colors.black45,
                          fontSize: selectedLevel == _level ? 48 : 24),
                      child: FittedBox(
                        child: Text(
                          _level.toUpperCase(),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
}

class GameTypeButtons extends StatelessWidget {
  final bool isGameOnline;
  final String selectedType;

  const GameTypeButtons(
      {Key? key, this.isGameOnline = false, required this.selectedType})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 2,
        child: Row(
          children: [
            "normal",
            if (isGameOnline) "closed",
            if (isGameOnline) "orderWise"
          ]
              .map(
                (_type) => Flexible(
                  child: TextButton(
                    onPressed: isGameOnline
                        ? () => context.read(setGameProvider).type = _type
                        : () => context.read(practiceProvider).type = _type,
                    child: AnimatedDefaultTextStyle(
                      duration: DurationCount.m500,
                      style: TextStyleFontTheme.luckiestGuy.copyWith(
                        color: selectedType == _type
                            ? Colors.white60
                            : Colors.black45,
                        fontSize: selectedType == _type ? 48 : 24,
                      ),
                      child: FittedBox(
                        child: Text(_type.toUpperCase()),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
}

class Point5Gap extends StatelessWidget {
  const Point5Gap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(),
        ),
      );
}

class SetGameLevel extends StatelessWidget {
  final String title;
  final String level;
  final bool isOnline;

  const SetGameLevel(
      {Key? key,
      required this.level,
      required this.title,
      this.isOnline = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SetGameTitle(title: title),
        Point5Gap(),
        Flexible(
          child: Center(
            child: Row(
              children: const ["easy", "medium", "hard"]
                  .map(
                    (_level) => TextButton(
                      onPressed: () => !isOnline
                          ? context.read(practiceProvider).level = _level
                          : context.read(setGameProvider).level = _level,
                      child: AnimatedDefaultTextStyle(
                        duration: DurationCount.m500,
                        style: TextStyleFontTheme.luckiestGuy.copyWith(
                            color: level == _level
                                ? Colors.white54
                                : Colors.black45,
                            fontSize: level == _level ? 48 : 24),
                        child: FittedBox(
                          child: Text(
                            _level.toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        )
      ],
    );
  }
}

class SetPlayerCount extends StatelessWidget {
  final bool isOnline;

  const SetPlayerCount({Key? key, required this.isOnline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = isOnline
        ? context.read(setGameProvider)
        : context.read(practiceProvider);
    return Flexible(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerAdjustButton(
              icon: Icons.chevron_left,
              arrowClick: notifier.playerCount == 2
                  ? null
                  : () => notifier.playerCount--,
            ),
            Flexible(
              //flex: 2,
              child: FractionallySizedBox(
                //widthFactor: 1,
                heightFactor: 1,
                child: FittedBox(
                  child: AnimatedSwitcher(
                    duration: DurationCount.m250,
                    child: Text(
                      "${notifier.playerCount}",
                      key: ValueKey(notifier.playerCount),
                      style: TextStyleFontTheme.luckiestGuy.copyWith(
                        color: Colors.white70,
                      ),
                      textScaleFactor: 5,
                    ),
                  ),
                ),
              ),
            ),
            PlayerAdjustButton(
              icon: Icons.chevron_right,
              arrowClick: notifier.playerCount == 6
                  ? null
                  : () => notifier.playerCount++,
            ),
          ],
        ),
      ),
    );
  }
}

class SetGameDetails extends StatelessWidget {
  final bool isOnline;

  const SetGameDetails({Key? key, required this.isOnline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = isOnline
        ? context.read(setGameProvider)
        : context.read(practiceProvider);
    return Flexible(
      child: FittedBox(
        child: AnimatedSwitcher(
          duration: DurationCount.m500,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation.drive(Tween(begin: 0, end: 1)),
            child: SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.25, 0.0),
                  end: const Offset(0.0, 0.0),
                ),
              ),
              child: child,
            ),
          ),
          child: Text(
            notifier.details,
            key: ValueKey(notifier.type),
            style: TextStyleFontTheme.poppins,
          ),
        ),
      ),
    );
  }
}

class StartGameText extends StatelessWidget {
  const StartGameText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FittedBox(
        child: Text(
          "Start Game",
          style: TextStyleFontTheme.luckiestGuy
              .copyWith(color: Colors.white70, fontSize: 36),
        ),
      );
}
