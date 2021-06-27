import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/enumFiles.dart';
import '/models/localIcon.dart';
import '/models/localPlayer.dart';

import 'common/durationCount.dart';
import 'common/gameBoardWidgets.dart';
import 'common/popup.dart';

import 'providers/authProvider.dart';
import 'providers/boardProvider.dart';
import 'providers/gameIconProvider.dart';
import 'providers/onlineBoardProvider.dart';
import 'providers/pageProvider.dart';
import 'results.dart';

//final _selectedListKey = GlobalKey<AnimatedListState>();

class GameBoard extends ConsumerWidget {
  const GameBoard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: GameBoard(),
        name: '/gameBoard',
        key: ValueKey('gameBoard'),
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = watch(onlineBoardNotifier);
    final gIconProvider = context.read(gameIconProvider);

    final String strColor = notifier.myPlayer?.color ?? "";
    final Color mColor = gIconProvider.iconColor(strColor);
    return Scaffold(
      backgroundColor: mColor,
      body: WillPopScope(
        onWillPop: () async => await showDialog(
          context: context,
          builder: (context) => ExitPopup(isScreenBoard: true),
        ),
        child: InitBoard(),
      ),
    );
  }
}

class InitBoard extends ConsumerWidget {
  const InitBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = watch(onlineBoardNotifier);
    final gIconProvider = context.read(gameIconProvider);

    final String myColor = notifier.myPlayer?.color ?? "";
    final Color mColor = gIconProvider.iconColor(myColor);

    final String currentColor = notifier.currentPlayer.color;
    final Color cColor = gIconProvider.iconColor(currentColor);

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: AnimatedContainer(
          duration: DurationCount.m500,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: List.from(
                List.generate(
                      7,
                      (_) => mColor.withOpacity(0.4),
                    ) +
                    List.generate(
                      3,
                      (_) => cColor.withOpacity(0.2),
                    ),
              ),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AnimatedSwitcher(
            duration: DurationCount.m500,
            child: watch(boardProvider).when(
              data: (_board) {
                context.read(onlineBoardNotifier).type = _board.type;
                return Stack(
                  children: [
                    ConfettiWidget(
                      confettiController: notifier.confetiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      // don't specify a direction, blast randomly
                      colors: notifier.confettiColors,
                      // manually specify
                      numberOfParticles: 25, // the colors to be used
                      //createParticlePath: drawStar,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BoardHeader(level: notifier.level),
                        GridIcons(icons: _board.icons),
                        PlayerList(players: _board.players)
                      ],
                    ),
                  ],
                );
              },
              loading: () {
                notifier.init();
                return Container();
              },
              error: (error, stackTrace) {
                print("Board Error");
                print(error);
                print(stackTrace);
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class OnlinePlayer extends StatelessWidget {
  final String id;

  const OnlinePlayer({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) => ProviderListener(
        provider: localPlayerProvider(id),
        onChange: (BuildContext context, AsyncValue<LocalPlayer> asyncValue) {
          asyncValue.whenData(
            (_player) {
              final firebaseUser = context.read(firebaseUserProvider!);
              final _notifier = context.read(onlineBoardNotifier);
              if (firebaseUser.uid == id) _notifier.myPlayer = _player;
              _notifier.replacePlayer(_player);
            },
          );
        },
        child: Consumer(
          builder: (context, watch, child) {
            final bool yourTurn = watch(currentIDProvider).maybeWhen(
              orElse: () => false,
              data: (value) => id == value,
            );

            return AnimatedSwitcher(
              duration: DurationCount.m500,
              child: watch(localPlayerProvider(id)).when(
                data: (player) =>
                    CardLocalPlayer(player: player, yourTurn: yourTurn),
                loading: () => Container(),
                error: (error, stackTrace) => Container(),
              ),
            );
          },
        ),
      );
}

class CardIcon extends StatelessWidget {
  final String id;

  const CardIcon({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.read(onlineBoardNotifier);
    final gameIcon = context.read(gameIconProvider);
    return ProviderListener(
      provider: iconProvider(id),
      onChange: (BuildContext context, AsyncValue<LocalIcon> async) {
        async.whenData(
          (_icon) async {
            notifier.replaceIcon(_icon);
            /*if (!_icon.checkFound() && notifier.type == GameType.orderWise)
              context.refresh(currentIconProvider);*/
            if (_icon.isFound) {
              /*if (notifier.type == GameType.orderWise)
                context.refresh(currentIconProvider);*/
              notifier.confettiColors = gameIcon.confettiColors(_icon.color);
              notifier.confetiController.play();
              final bool allFound =
                  notifier.icons.every((element) => element.isFound);
              if (allFound) {
                print("All Found $allFound");
                //final analytics = context.read(firebaseAnalyticsProvider);
                await context.read(updateStatsProvider.future);
                //analytics.setCurrentScreen(screenName: "game_results_screen");
                context.read(pageProvider).replace(GameResults.toMaterialPage);
              }
            }
          },
        );
      },
      child: Consumer(
        builder: (ctx, watch, c) {
          final gameIcon = ctx.read(gameIconProvider);
          final ctxNotifier = ctx.read(onlineBoardNotifier);

          final String myColor = ctxNotifier.myPlayer?.color ?? "";

          final Color iconBoxColor = gameIcon.iconBoxColor(myColor);

          final bool yourTurn = watch(currentIDProvider).maybeWhen(
            orElse: () => false,
            data: (value) {
              final firebaseUser = ctx.read(firebaseUserProvider!);
              return firebaseUser.uid == value;
            },
          );

          return AnimatedSwitcher(
            duration: DurationCount.m500,
            child: watch(iconProvider(id)).when(
              data: (_icon) => LocalIconCard(
                icon: _icon,
                iconTap: yourTurn && !ctxNotifier.loading
                    ? () async {
                        ctxNotifier.loading = true;
                        await context
                            .read(btnClickProvider(id).future)
                            .whenComplete(
                              () => ctxNotifier.loading = false,
                            );
                      }
                    : null,
                yourTurn: yourTurn,
                iconColor: iconBoxColor,
                type: ctxNotifier.type,
              ),
              loading: () => Container(),
              error: (error, stackTrace) => Container(),
            ),
          );
        },
      ),
    );
  }
}

class BoardHeader extends StatelessWidget {
  final String level;

  const BoardHeader({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  PlayerName(),
                  //if (level != "easy") SelectedIcons(),
                ],
              ),
            ),
            GameLoader(),
          ],
        ),
      );
}

class GameLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = context.read(onlineBoardNotifier);
    final gIconProvider = context.read(gameIconProvider);

    final String myColor = notifier.myPlayer?.color ?? "";
    final Color mColor = gIconProvider.iconColor(myColor);
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: AnimatedOpacity(
              duration: DurationCount.m250,
              opacity: context.read(onlineBoardNotifier).loading ? 1 : 0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mColor),
              ),
            ),
          ),
          if (notifier.type == GameType.orderWise)
            OrderWiseIcon(iconColor: myColor)
        ],
      ),
    );
  }
}

class OrderWiseIcon extends ConsumerWidget {
  final String iconColor;

  const OrderWiseIcon({Key? key, required this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final gameIcon = context.read(gameIconProvider);

    return Flexible(
      child: AnimatedSwitcher(
        duration: DurationCount.m500,
        child: watch(currentIconProvider).when(
          data: (_iconCode) => _iconCode.isEmpty
              ? Container()
              : Icon(
                  gameIcon.gameIcon(_iconCode),
                  key: ValueKey(_iconCode),
                  size: 48,
                  color: gameIcon.iconColor(iconColor),
                ),
          loading: () => Container(),
          error: (Object error, StackTrace? stackTrace) => Container(),
        ),
      ),
    );
  }
}

class PlayerName extends ConsumerWidget {
  const PlayerName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = watch(onlineBoardNotifier);
    //final iconProvider = watch(gameIconProvider);
    final LocalPlayer? player = notifier.currentPlayer;
    final bool isItYou = player == notifier.myPlayer;
    return Flexible(
      flex: 3,
      child: ProviderListener(
        provider: currentIDProvider,
        onChange: (BuildContext context, AsyncValue<String> asyncID) {
          asyncID.whenData(
            (_id) async {
              final board = await context.read(boardProvider.future);
              final int currentIndex = board.players.indexOf(_id);
              context.read(onlineBoardNotifier).currentIndex = currentIndex;
            },
          );
        },
        child: PlayerNameState(
          player: player!,
          keyValue: notifier.currentIndex,
          isItYou: isItYou,
        ),
      ),
    );
  }
}
