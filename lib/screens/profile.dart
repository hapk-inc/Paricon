import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:paricon/models/stats.dart';
import 'package:paricon/screens/providers/pageProvider.dart';

import 'common/durationCount.dart';
import 'common/paddingTheme.dart';
import 'common/popup.dart';
import 'common/statsValue.dart';
import 'common/textTheme.dart';
import 'providers/authProvider.dart';
import 'providers/packageInfoProvider.dart';
import 'providers/playerProvider.dart';

class ProfileScreen extends ConsumerWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
        child: ProfileScreen(),
        name: '/profile',
        key: ValueKey('profile'),
      );

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    TabController? _tabController;
    final orientation = MediaQuery.of(context).orientation;

    List<Widget> profileNameIdList(
            {String? name, String? id, bool? fromLeft}) =>
        <Widget>[
          Flexible(
            child: Container(
              constraints: BoxConstraints.expand(),
              child: FittedBox(
                child: Icon(
                  Icons.person,
                  color: Colors.pink[700],
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: PaddingTheme.all8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: AutoSizeText(
                            name ?? "NoOne",
                            maxFontSize: 64,
                            wrapWords: false,
                            minFontSize: 16,
                            maxLines: 2,
                            style: TextStyleFontTheme.luckiestGuy.copyWith(
                              color: Colors.pink[700],
                              fontSize: 72,
                            ),
                            //textScaleFactor: 2.5,
                          ),
                        ),
                        Flexible(
                          child: TextButton(
                            /* onPressed: () => context
                                .read(pageProvider)
                                .addNext(EnterName.toMaterialPage),*/
                            onPressed: () async => await showDialog(
                                context: context,
                                builder: (context) => EditNamePopUp()),
                            child: Text(
                              "EDIT",
                              style: TextStyleFontTheme.poppins
                                  .copyWith(color: Colors.black38),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        "ID: " + (id ?? "00000"),
                        style: TextStyleFontTheme.meriendaOne.copyWith(
                          //fontSize: 24,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        //textScaleFactor: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.pink[200],
        appBar: AppBar(
          backgroundColor: Colors.pink,
          actions: [
            SignOutButton(),
          ],
        ),
        body: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: AnimatedSwitcher(
                  duration: DurationCount.m500,
                  child: watch(profileProvider).when(
                    data: (value) => orientation == Orientation.portrait
                        ? value == null
                            ? NotCreated(key: ValueKey("noProfile"))
                            : Column(
                                key: ValueKey(value),
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Row(
                                      children: profileNameIdList(
                                        name: value.name,
                                        id: value.userID.toString(),
                                      ),
                                    ),
                                  ),
                                  LevelTabs(),
                                  Flexible(
                                    flex: 4,
                                    child: TabBarView(
                                      children: value.stats!
                                          .map(
                                            (e) => Card(
                                              color: Colors.pink[100],
                                              elevation: 4,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Flexible(
                                                      child: e.played == 0
                                                          ? NotYetPlayedWidget()
                                                          : MyLevelStats(
                                                              stats: e)),
                                                  if (e.prevStats != null)
                                                    PrevStatsList(
                                                      prevStats: e.prevStats!,
                                                    )
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: _tabController,
                                    ),
                                  ),
                                  Spacer(),
                                  if (watch(firebaseUserProvider!).isAnonymous)
                                    AnonymousUserWidget()
                                ],
                              )
                        : Row(
                            children: [
                              Flexible(
                                child: Column(
                                  children: profileNameIdList(
                                      name: value!.name,
                                      id: value.userID.toString()),
                                ),
                              ),
                              Flexible(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LevelTabs(),
                                  Flexible(
                                    flex: 3,
                                    child: TabBarView(
                                      children: value.stats!
                                          .map(
                                            (e) => Card(
                                              color: Colors.pink[100],
                                              elevation: 8,
                                              child: e.played == 0
                                                  ? NotYetPlayedWidget()
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        StatsValue(
                                                          value: e.played!
                                                              .toDouble(),
                                                          header: "GAMES",
                                                        ),
                                                        StatsValue(
                                                          value:
                                                              e.win!.toDouble(),
                                                          header: "WINS",
                                                        ),
                                                        StatsValue(
                                                          value: e.avg,
                                                          header: "AVG. SCORE",
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          )
                                          .toList(growable: false),
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: _tabController,
                                    ),
                                  ),
                                  Spacer(),
                                  if (watch(firebaseUserProvider!).isAnonymous)
                                    AnonymousUserWidget()
                                ],
                              ))
                            ],
                          ),
                    loading: () => Container(),
                    error: (error, stackTrace) {},
                  )),
              flex: 9,
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: DurationCount.m500,
                child: watch(packageInfoProvider!).when(
                  data: (value) => Container(
                    padding: PaddingTheme.all8,
                    constraints: BoxConstraints.tightForFinite(),
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      child: Text(
                        "Version : " + value.version,
                        style: TextStyleFontTheme.bangers.copyWith(
                          color: Colors.black38,
                        ),
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  loading: () => Container(),
                  error: (error, stackTrace) => Container(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NotCreated extends StatelessWidget {
  const NotCreated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AutoSizeText(
              "Your profile is not created",
              style: TextStyleFontTheme.poppins.copyWith(
                color: Colors.black45,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Lottie.asset(
              'assets/lottie/createProfile.json',
              fit: BoxFit.cover,
            ),
          ),
          Flexible(
            child: FractionallySizedBox(
              widthFactor: 0.75,
              heightFactor: 0.25,
              child: ElevatedButton(
                onPressed: () => context
                    .read(createProfileProvider.future)
                    .whenComplete(() => context.refresh(profileProvider)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.pink[600]),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  padding: MaterialStateProperty.all(PaddingTheme.all8),
                ),
                child: AutoSizeText(
                  "Click to create your profile",
                  style: TextStyleFontTheme.poppins.copyWith(fontSize: 16),
                ),
              ),
            ),
          )
        ],
      );
}

class PrevStatsList extends StatelessWidget {
  final Map prevStats;
  const PrevStatsList({Key? key, required this.prevStats}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          child: Text(
            "Previous Stats will be displayed here \nin the next update",
            style: TextStyleFontTheme.poppins.copyWith(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class MyLevelStats extends StatelessWidget {
  final Stats stats;
  const MyLevelStats({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingTheme.all8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          StatsValue(value: stats.played, header: "GAMES"),
          StatsValue(value: stats.win, header: "WINS"),
          StatsValue(value: stats.avg, header: "AVG. SCORE"),
        ],
      ),
    );
  }
}

class AnonymousUserWidget extends StatelessWidget {
  const AnonymousUserWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showSnackBar({String message = "", Color bgColor = Colors.black87}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 8,
          content: AutoSizeText(
            message,
            style: TextStyleFontTheme.poppins,
            maxLines: 1,
          ),
          duration: DurationCount.sec1,
          backgroundColor: bgColor,
        ),
      );
    }

    return Flexible(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                "Will clear your data once you've signed out",
                style: TextStyleFontTheme.poppins.copyWith(color: Colors.pink),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: AutoSizeText(
                    "Anonymous User",
                    style: TextStyleFontTheme.poppins
                        .copyWith(color: Colors.black38, fontSize: 16),
                    maxLines: 1,
                  ),
                ),
                Flexible(
                  //flex: 2,
                  child: ElevatedButton(
                    /* onPressed: () => context.read(reSignInProvider.future).then(
                      (dynamic x) {
                        context.read(pageProvider).remove();
                        if (x is FirebaseAuthException) {
                          switch (x.code) {
                            case "credential-already-in-use":
                              showSnackBar(message: x.message!);
                              break;
                            default:
                              showSnackBar(message: x.message!);
                          }
                        } else
                          showSnackBar(
                            message: "Successfully linked Gmail Account",
                            bgColor: Colors.lightGreen,
                          );
                      },
                    ).catchError(
                      (error, stacktrace) {
                        showSnackBar(
                          message: "Sign-In Error",
                          bgColor: Colors.indigo,
                        );
                      },
                    ),*/
                    onPressed: () => context.read(reSignInProvider.future).then(
                      (value) {
                        context.read(pageProvider).remove();
                        showSnackBar(
                          message: "Successfully linked Gmail Account",
                          bgColor: Colors.lightGreen,
                        );
                      },
                    ).catchError(
                      (error, StackTrace? stackTrace) {
                        if (error is FirebaseAuthException) {
                          switch (error.code) {
                            case "credential-already-in-use":
                              showSnackBar(message: error.message!);
                              break;
                            default:
                              {
                                FirebaseCrashlytics.instance.recordError(
                                  error,
                                  stackTrace,
                                  reason: 'Google ReSign Error',
                                  fatal: false,
                                );
                                showSnackBar(message: error.message!);
                              }
                          }
                        } else if (error is PlatformException) {
                          FirebaseCrashlytics.instance.recordError(
                            error,
                            stackTrace,
                            reason: 'Google ReSign Error',
                            fatal: false,
                          );
                          showSnackBar(message: error.message!);
                        }
                      },
                    ),
                    child: AutoSizeText.rich(
                      //"Want to Sign in Google?",
                      TextSpan(
                        text: "sign in with ",
                        children: [
                          TextSpan(
                            text: "Google",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyleFontTheme.poppins.copyWith(
                        color: Colors.white60,
                        fontWeight: FontWeight.w200,
                      ),
                      maxLines: 1,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.pink[600]),
                      elevation: MaterialStateProperty.all(8),
                      //padding: MaterialStateProperty.all(PaddingTheme.all16),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotYetPlayedWidget extends StatelessWidget {
  const NotYetPlayedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        child: Text(
          "This season not started",
          style: TextStyleFontTheme.bangers.copyWith(
            color: Colors.brown,
            fontSize: 24,
          ),
        ),
      );
}

class LevelTabs extends StatelessWidget {
  const LevelTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TabBar(
        labelStyle: TextStyleFontTheme.poppins.copyWith(
          fontSize: 20,
          color: Colors.black54,
        ),
        tabs: const ['Easy', 'Medium', 'Hard']
            .map(
              (e) => Tab(
                child: Container(
                  padding: PaddingTheme.all4,
                  constraints: BoxConstraints.expand(),
                  child: FittedBox(
                    child: Text(e),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
      fit: FlexFit.tight,
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.read(signOutProvider!),
      child: Text(
        "SIGN OUT",
        style:
            TextStyleFontTheme.poppins.copyWith(letterSpacing: 5, fontSize: 16),
      ),
    );
  }
}
