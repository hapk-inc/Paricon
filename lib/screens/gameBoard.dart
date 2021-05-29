import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'common/textTheme.dart';
import 'providers/authProvider.dart';
import 'providers/boardProvider.dart';
import 'providers/gameIconProvider.dart';
import 'providers/pageProvider.dart';
import 'providers/roomNotifierProvider.dart';
import 'results.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({Key? key}) : super(key: key);

  static MaterialPage toMaterialPage() => MaterialPage(
        child: GameBoard(),
        name: '/gameBoard',
        key: ValueKey('gameBoard'),
      );
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //final firebaseUser = watch(currentUserProvider);

    Future<bool> _onBackPressed() async => await showDialog(
          context: context,
          builder: (context) => ExitPopup(isScreenBoard: true),
        );
    final gameIcon = watch(gameIconProvider!);
    final yourColor = watch(yourColorProvider).data?.value;

    final board = watch(boardProvider).data?.value;

    return Scaffold(
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: SafeArea(
          child: ProviderListener(
            provider: allIconsFoundProvider,
            onChange: (BuildContext context, AsyncValue<int> iconsFound) {
              iconsFound.whenData(
                (_value) async {
                  if (board == null) return;
                  final num iconCount = board.icons.length;
                  //if (value % 2 == 0 && value > 8) {
                  if (_value == iconCount) {
                    print("Game Over");
                    final isUpdated = await watch(updateStatsProvider!.future);
                    if (isUpdated)
                      context
                          .read(pageProvider)
                          .replace(GameResults.toMaterialPage());
                  }
                },
              );
            },
            child: AnimatedSwitcher(
              duration: DurationCount.m500,
              child: watch(boardProvider).when(
                data: (value) => MediaQuery.of(context).orientation ==
                        Orientation.portrait
                    ? AnimatedContainer(
                        duration: DurationCount.m500,
                        color: gameIcon.iconColor(yourColor)!.withOpacity(0.25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(child: CurrentPlayerName()),
                            Flexible(
                              flex: 7,
                              child: GridIcons(icons: value.icons),
                            ),
                            Flexible(
                              flex: 2,
                              child: GamePlayers(players: value.players),
                            )
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Flexible(
                            flex: 7,
                            child: GridIcons(icons: value.icons),
                          ),
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: [
                                Flexible(child: CurrentPlayerName()),
                                Flexible(
                                  child: GamePlayers(players: value.players),
                                  flex: 3,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                loading: () => Container(),
                error: (error, stackTrace) => Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> playerWidgets(LocalPlayer localPlayer, double newHeight) => [
      Flexible(
        flex: 2,
        child: FittedBox(
          child: AnimatedSwitcher(
            duration: DurationCount.m500,
            child: Text(
              localPlayer.pts.toString(),
              key: ValueKey(localPlayer.pts),
              style: TextStyleFontTheme.luckiestGuy
                  .copyWith(fontSize: newHeight * 0.75, color: Colors.white70),
            ),
          ),
        ),
      ),
      Flexible(
        child: FractionallySizedBox(
          widthFactor: 0.25,
          heightFactor: 0.25,
        ),
      ),
      Flexible(
        child: FittedBox(
          child: Text(
            localPlayer.name!,
            style: TextStyleFontTheme.reggaeOne.copyWith(
              fontSize: newHeight * 0.5,
              color: Colors.white60,
            ),
          ),
        ),
      )
    ];

class GamePlayers extends ConsumerWidget {
  final List? players;
  const GamePlayers({Key? key, this.players}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final int maxCount = players!.length > 4 ? players!.length : 4;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final double newH = (MediaQuery.of(context).size.height * 0.75) / maxCount;
    final gameIcon = watch(gameIconProvider!);
    if (orientation == Orientation.portrait)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: players!.map(
          (e) {
            final bool _yourTurn = watch(currentIDProvider).maybeWhen(
              orElse: () => false,
              data: (value) {
                return e == value;
              },
            );
            return Flexible(
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: AnimatedSwitcher(
                  duration: DurationCount.m500,
                  child: watch(localPlayerProvider(e)).when(
                    data: (player) => AnimatedContainer(
                      duration: DurationCount.m500,
                      transform:
                          Matrix4.rotationZ(player.isActive! ? -0.025 : 0),
                      //padding: ,
                      decoration: BoxDecoration(
                        color: gameIcon
                            .iconBoxColor(player.color)!
                            .withOpacity(_yourTurn ? 1 : 0.25),
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: MediaQuery.of(context).size.longestSide !=
                                MediaQuery.of(context).size.width
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: playerWidgets(player, newH),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: playerWidgets(player, newH),
                              ),
                      ),
                    ),
                    loading: () => Container(),
                    error: (error, stackTrace) => Container(),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      );
    else
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: players!
            .map(
              (e) => Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  heightFactor: 0.9,
                  child: AnimatedSwitcher(
                    duration: DurationCount.m500,
                    child: watch(localPlayerProvider(e)).when(
                      data: (player) => AnimatedContainer(
                        duration: DurationCount.m500,
                        transform:
                            Matrix4.rotationZ(player.isActive! ? -0.025 : 0),
                        //padding: ,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(1),
                          borderRadius: BorderRadius.circular(4.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: MediaQuery.of(context).size.longestSide ==
                                  MediaQuery.of(context).size.width
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: playerWidgets(player, newH),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: playerWidgets(player, newH),
                                  ),
                                ),
                        ),
                      ),
                      loading: () => Container(),
                      error: (error, stackTrace) => Container(),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
  }
}

class GridIcons extends StatelessWidget {
  final List? icons;
  const GridIcons({Key? key, this.icons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double newRatio =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? (MediaQuery.of(context).size.longestSide * 0.75) /
                MediaQuery.of(context).size.shortestSide
            : 1;
    return GridView.count(
      padding: PaddingTheme.all8,
      crossAxisCount:
          context.read(gameIconProvider!).crossAxisCount(icons!.length),
      shrinkWrap: true,
      childAspectRatio: newRatio,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      children: icons!
          .map(
            (_id) => IconCard(
              id: _id,
            ),
          )
          .toList(),
    );
  }
}

class IconCard extends ConsumerWidget {
  final String? id;
  const IconCard({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final firebaseUser = watch(firebaseUserProvider!);
    final roomNotifier = watch(roomNotifierProvider);
    final gameIcnProvider = watch(gameIconProvider!);

    //final gameIcon = watch(gameIconProvider!);
    final yourColor = watch(yourColorProvider).data?.value;

    bool _yourTurn = watch(currentIDProvider).maybeWhen(
      orElse: () => false,
      data: (value) {
        return firebaseUser.uid == value;
      },
    );
    return AnimatedSwitcher(
      duration: DurationCount.m500,
      child: watch(iconProvider!(id!)).when(
        data: (_icon) {
          final bool checkFound = _icon.isCheck! || _icon.isFound!;
          final info = IconInfo(id, _icon.iconCode);
          return AnimatedContainer(
            duration: DurationCount.m500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
            ),
            /*transform: Matrix4.translationValues(-5, 5, 0)
              ..rotateZ(
                (!checkFound ? (Random.secure().nextBool() ? -pi : pi) : -pi) /
                    (checkFound ? 60 : 15),
              ),*/
            transform: Matrix4.rotationZ(
                (!checkFound ? (Random.secure().nextBool() ? -pi : pi) : -pi) /
                    (checkFound ? 60 : 15)),
            child: ClipRect(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: AnimatedSwitcher(
                  duration: DurationCount.m500,
                  child: checkFound
                      ? AnimatedContainer(
                          duration: DurationCount.m500,
                          alignment: Alignment.center,
                          padding: PaddingTheme.all4,
                          decoration: BoxDecoration(
                            color: _icon.isFound!
                                ? gameIcnProvider
                                    .iconBoxColor(yourColor)!
                                    .withOpacity(0.2)
                                : gameIcnProvider.iconBoxColor(yourColor),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: FittedBox(
                            child: Icon(
                              gameIcnProvider.gameIcon(_icon.iconCode),
                              color: _icon.isFound!
                                  ? gameIcnProvider.iconColor(_icon.color)
                                  : Colors.white70,
                              size: MediaQuery.of(context).size.height,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _yourTurn && !roomNotifier.loading
                              ? () async {
                                  roomNotifier.loading = true;
                                  await context
                                      .read(btnClickProvider(info).future)
                                      .whenComplete(
                                        () => roomNotifier.loading = false,
                                      );
                                }
                              : null,
                          child: Container(
                            constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                                color: gameIcnProvider.iconBoxColor(yourColor),
                                borderRadius: BorderRadius.circular(4.0)),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
        loading: () => Container(),
        error: (error, stackTrace) => Container(),
      ),
    );
  }
}

class CurrentPlayerName extends ConsumerWidget {
  const CurrentPlayerName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final firebaseUser = watch(firebaseUserProvider!);
    bool _yourTurn = watch(currentIDProvider).maybeWhen(
      orElse: () => false,
      data: (value) => firebaseUser.uid == value,
    );

    return Container(
      padding: PaddingTheme.all8,
      alignment: Alignment.bottomLeft,
      child: AnimatedSwitcher(
        duration: DurationCount.m500,
        child: _yourTurn
            ? PlayerName(name: "Your turn")
            : watch(nameProvider!).when(
                data: (value) => PlayerName(name: value),
                error: (Object error, StackTrace? stackTrace) => Container(),
                loading: () => Container(),
              ),
      ),
    );
  }
}

class PlayerName extends ConsumerWidget {
  final String? name;
  const PlayerName({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final gameIcon = watch(gameIconProvider!);
    final currentColor = watch(currentPlayerColor).data?.value;
    return FittedBox(
      child: OutlineBorderText(
        strokeColor: Colors.white70,
        strokeWidth: 5,
        child: Text(
          name!,
          key: ValueKey(name),
          style: TextStyleFontTheme.luckiestGuy.copyWith(
            color: gameIcon.iconColor(currentColor),
            fontSize: MediaQuery.of(context).size.height * 0.1,
          ),
        ),
      ),
    );
  }
}

class OutlineBorderText extends StatelessWidget {
  OutlineBorderText({
    required this.child,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeWidth = 6.0,
    this.strokeColor = const Color.fromRGBO(53, 0, 71, 1),
  }) : assert(child is Text);

  /// the stroke cap style
  final StrokeCap strokeCap;

  /// the stroke joint style
  final StrokeJoin strokeJoin;

  /// the stroke width
  final double strokeWidth;

  /// the stroke color
  final Color strokeColor;

  /// the [Text] widget to apply stroke on
  final Text child;

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    if (child.style != null) {
      style = child.style!.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = strokeCap
          ..strokeJoin = strokeJoin
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
        color: null,
      );
    } else {
      style = TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = strokeCap
          ..strokeJoin = strokeJoin
          ..strokeWidth = strokeWidth
          ..color = strokeColor,
      );
    }
    return Stack(
      alignment: Alignment.center,
      textDirection: child.textDirection,
      children: <Widget>[
        Text(
          child.data!,
          style: style,
          maxLines: child.maxLines,
          overflow: child.overflow,
          semanticsLabel: child.semanticsLabel,
          softWrap: child.softWrap,
          strutStyle: child.strutStyle,
          textAlign: child.textAlign,
          textDirection: child.textDirection,
          textScaleFactor: child.textScaleFactor,
        ),
        child,
      ],
    );
  }
}
