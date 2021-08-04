//import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';

import '/models/enumFiles.dart';
import '/models/localIcon.dart';
import '/models/localPlayer.dart';
import 'common/durationCount.dart';
import 'common/gameBoardWidgets.dart';
import 'common/popup.dart';
import 'common/textTheme.dart';
import 'providers/adStateProvider.dart';
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

class InitBoard extends StatelessWidget {
  const InitBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Container(
          color: Colors.white,
          child: Consumer(
            builder: (context, watch, child) {
              final notifier = watch(onlineBoardNotifier);
              final gIconProvider = context.read(gameIconProvider);

              final String myColor = notifier.myPlayer?.color ?? "";
              final Color mColor = gIconProvider.iconColor(myColor);

              final String currentColor = notifier.currentPlayer.color;
              final Color cColor = gIconProvider.iconColor(currentColor);
              return AnimatedContainer(
                duration: DurationCount.m500,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: List.from(
                      List.generate(
                            6,
                            (_) => mColor.withOpacity(0.4),
                          ) +
                          List.generate(
                            4,
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
                            confettiController: notifier.confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            // don't specify a direction, blast randomly
                            //colors: notifier.confettiColors,
                            colors: context
                                .read(gameIconProvider)
                                .confettiColors(notifier.confettiColors),
                            // manually specify
                            numberOfParticles: 25, // the colors to be used
                            //createParticlePath: drawStar,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              BoardHeader(level: notifier.level),
                              GridIcons(icons: _board.icons),
                              PlayerList(players: _board.players),
                              //PlayerListWheel(players: _board.players),
                              Spacer()
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () {
                      notifier.init();
                      return BoardLoading();
                    },
                    error: (err, StackTrace? stackTrace) {
                      final error = err as Error;
                      FirebaseCrashlytics.instance.recordError(
                        error,
                        stackTrace,
                        reason: 'Board Error',
                        fatal: true,
                      );
                      return ErrorGameBoard(error: error);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class BoardLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Lottie.asset(
          'assets/lottie/square-loading.json',
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.contain,
        ),
      );
}

class ErrorGameBoard extends StatelessWidget {
  final Error error;

  const ErrorGameBoard({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Lottie.asset(
                'assets/lottie/sad.json',
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
                fit: BoxFit.contain,
              ),
            ),
            Flexible(
              child: AutoSizeText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Sorry",
                      style: TextStyleFontTheme.poppins.copyWith(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(text: "..seems we have some issue\n"),
                    TextSpan(text: "Kindly reopen the app\n"),
                    TextSpan(
                      text: "Re-enter",
                      style: TextStyleFontTheme.poppins.copyWith(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: " the same Room code"),
                  ],
                ),
                style: TextStyleFontTheme.poppins.copyWith(
                  color: Colors.black38,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
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

    return ProviderListener(
      provider: iconProvider(id),
      onChange: (BuildContext context, AsyncValue<LocalIcon> async) {
        async.whenData(
          (_icon) async {
            final player = AudioCache(
              fixedPlayer: AudioPlayer(
                mode: PlayerMode.LOW_LATENCY,
              ),
              respectSilence: true,
              duckAudio: true,
            );
            if (!notifier.icons.contains(_icon)) {
              player.load('audios/${_icon.audio}.wav');
            }
            notifier.replaceIcon(_icon);

            if (_icon.isCheck) {
              player.play('audios/${_icon.audio}.wav');
            }
            if (_icon.isFound) {
              notifier.confettiColors = _icon.color;
              notifier.confettiController.play();

              final bool allFound =
                  notifier.icons.every((element) => element.isFound);
              if (allFound) {
                context.read(updateStatsProvider.future);
                final adState = context.read(adStateProvider);
                await adState.initialization.then(
                  (status) {
                    InterstitialAd.load(
                      adUnitId: adState.interstitialAdUnitId,
                      request: AdRequest(),
                      adLoadCallback: InterstitialAdLoadCallback(
                        onAdLoaded: (_ad) {
                          _ad
                            ..show()
                            ..fullScreenContentCallback =
                                FullScreenContentCallback(
                              onAdDismissedFullScreenContent: (ad) {
                                context
                                    .read(pageProvider)
                                    .replace(GameResults.toMaterialPage);
                              },
                            );
                        },
                        onAdFailedToLoad: (LoadAdError error) {
                          FirebaseCrashlytics.instance.recordError(
                            error.message,
                            null,
                            reason: 'Interstitial Ad Error',
                            fatal: false,
                          );
                          context
                              .read(pageProvider)
                              .replace(GameResults.toMaterialPage);
                        },
                      ),
                    );
                  },
                );
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
