import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localPlayer.dart';
import 'package:paricon/screens/providers/practiceProvider.dart';
import '/screens/gameBoard.dart';

import '/models/enumFiles.dart';
import '/screens/providers/gameIconProvider.dart';
import '/models/localIcon.dart';
import 'durationCount.dart';
import 'outlineBorder.dart';
import 'paddingTheme.dart';
import 'textTheme.dart';

class GridIcons extends StatelessWidget {
  final List icons;
  final bool isOnline;

  const GridIcons({required this.icons, this.isOnline = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 6,
      child: GridView.builder(
        itemCount: icons.length,
        padding: icons.length == 16 ? PaddingTheme.all16 : PaddingTheme.all8,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              context.read(gameIconProvider).crossAxisCount(icons.length),
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
        ),
        itemBuilder: (context, index) {
          if (isOnline) return CardIcon(id: icons[index]);
          final practice = context.read(practiceProvider);
          return LocalIconCard(
            icon: icons[index],
            iconTap:
                !practice.loading ? () => practice.validateIcons(index) : null,
          );
        },
      ),
    );
  }
}

class PlayerList extends StatelessWidget {
  final List players;
  final bool isOnline;

  const PlayerList({required this.players, this.isOnline = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int maxSize = players.length > 3 ? players.length : 3;
    return Flexible(
      flex: 2,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: players.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        //padding: PaddingTheme.all16,
        itemBuilder: (context, index) => SizedBox(
          width: MediaQuery.of(context).size.width / (maxSize + 0.25),
          child: isOnline
              ? OnlinePlayer(
                  id: players[index],
                )
              : CardLocalPlayer(
                  player: players[index],
                  yourTurn:
                      index == context.read(practiceProvider).currentIndex,
                ),
        ),
      ),
    );
  }
}

class LocalIconCard extends StatelessWidget {
  final LocalIcon icon;
  final Color iconColor;
  final VoidCallback? iconTap;
  final GameType type;
  final bool yourTurn;

  const LocalIconCard({
    Key? key,
    required this.icon,
    this.iconColor = Colors.blueGrey,
    this.type = GameType.normal,
    required this.iconTap,
    this.yourTurn = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
              color: icon.isFound ? Colors.white70 : iconColor,
            ),
            child: AnimatedSwitcher(
              duration: DurationCount.m500,
              child: !icon.checkFound()
                  ? InkWell(onTap: iconTap)
                  : icon.isFound
                      ? ShowFoundIcon(icon: icon)
                      : type == GameType.close && !yourTurn
                          ? DisableIcon()
                          : ShowCheckIcon(
                              iconCode: icon.iconCode,
                              color: iconColor,
                            ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShowCheckIcon extends StatelessWidget {
  final String iconCode;
  final Color color;

  const ShowCheckIcon({Key? key, required this.iconCode, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameIcon = context.read(gameIconProvider);

    return Container(
      padding: PaddingTheme.all4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: FittedBox(
          child: Icon(
            gameIcon.gameIcon(iconCode),
            color: Colors.white70,
            size: 72,
          ),
        ),
      ),
    );
  }
}

class ShowFoundIcon extends StatelessWidget {
  final LocalIcon icon;

  const ShowFoundIcon({Key? key, required this.icon}) : super(key: key);

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
            gameIcon.gameIcon(icon.iconCode),
            color: gameIcon.iconColor(icon.color),
            size: 72,
          ),
        ),
      ),
    );
  }
}

class DisableIcon extends StatelessWidget {
  const DisableIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      margin: PaddingTheme.all4,
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class PlayerNameState extends StatelessWidget {
  final LocalPlayer player;
  final bool isItYou;
  final int keyValue;

  const PlayerNameState({
    Key? key,
    required this.player,
    this.isItYou = false,
    required this.keyValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: PaddingTheme.all8,
        alignment: Alignment.centerLeft,
        child: AnimatedSwitcher(
          duration: DurationCount.m500,
          child: FittedBox(
            child: OutlineBorderText(
              strokeColor: Colors.white70,
              strokeWidth: 5,
              child: Text(
                isItYou ? "Your Turn" : player.name!,
                key: ValueKey(keyValue),
                style: TextStyleFontTheme.luckiestGuy.copyWith(
                  color: context.read(gameIconProvider).iconColor(player.color),
                  fontSize: MediaQuery.of(context).size.height * 0.075,
                ),
              ),
            ),
          ),
        ),
      );
}

class CardLocalPlayer extends StatelessWidget {
  final LocalPlayer player;
  final bool yourTurn;

  const CardLocalPlayer(
      {Key? key, required this.player, required this.yourTurn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconProvider = context.read(gameIconProvider);
    return AnimatedContainer(
      margin: EdgeInsets.all(4.0),
      duration: DurationCount.m500,
      transform: Matrix4.rotationZ(yourTurn ? -0.05 : 0),
      decoration: BoxDecoration(
        color: iconProvider
            .iconBoxColor(player.color)
            .withOpacity(yourTurn ? 1 : 0.1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: iconProvider.iconColor(player.color).withOpacity(0.1),
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      padding: PaddingTheme.all16,
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: DurationCount.m250,
        style: TextStyleFontTheme.luckiestGuy.copyWith(
            fontSize: yourTurn ? 24 : 16,
            color: yourTurn ? Colors.white60 : Colors.black26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 3,
              child: FractionallySizedBox(
                heightFactor: 0.9,
                child: Container(
                  constraints: BoxConstraints.expand(),
                  child: FittedBox(
                    child: AnimatedSwitcher(
                      duration: DurationCount.m500,
                      child: Text(
                        player.pts.toString(),
                        key: ValueKey(player.pts),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              //flex: 2,
              child: FractionallySizedBox(
                heightFactor: 0.9,
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: FittedBox(
                    child: Text(
                      player.name!,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Path drawStar(Size size) {
  // Method to convert degree to radians
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}

/*class SelectedIcons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameIcon = context.read(gameIconProvider);
    final notifier = context.read(onlineBoardNotifier);
    return Flexible(
      flex: 2,
      child: AnimatedList(
        key: _selectedListKey,
        scrollDirection: Axis.horizontal,
        initialItemCount: 0,
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) =>
                SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(-0.5, 0.0),
              end: const Offset(0.5, 0.0),
            ),
          ),
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0, end: 1)),
            child: Container(
              padding: PaddingTheme.all4,
              child: FittedBox(
                child: Icon(
                  gameIcon.gameIcon(notifier.selectedIcons[index].iconCode),
                  size: 48,
                  color:
                      gameIcon.iconColor(notifier.selectedIcons[index].color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
