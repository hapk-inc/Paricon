import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                            //name /*+ "\nasdf"*/ ?? "NoOne",
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
                  child: watch(profileProvider!).when(
                    data: (value) => orientation == Orientation.portrait
                        ? Column(
                            children: [
                              Flexible(
                                flex: 3,
                                child: Row(
                                  children: profileNameIdList(
                                    name: value.name ?? "NoOne",
                                    id: value.userID.toString(),
                                  ),
                                ),
                              ),
                              LevelTabs(),
                              Flexible(
                                flex: 3,
                                child: TabBarView(
                                  children: value.stats!
                                      .map(
                                        (e) => Card(
                                          color: Colors.pink[100],
                                          elevation: 4,
                                          child: e.played == 0
                                              ? NotYetPlayedWidget()
                                              : Padding(
                                                  padding: PaddingTheme.all8,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      StatsValue(
                                                        value: e.played,
                                                        header: "GAMES",
                                                      ),
                                                      StatsValue(
                                                        value: e.win,
                                                        header: "WINS",
                                                      ),
                                                      StatsValue(
                                                        value: e.avg,
                                                        header: "AVG. SCORE",
                                                      ),
                                                    ],
                                                  ),
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
                                      name: value.name,
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

class AnonymousUserWidget extends StatelessWidget {
  const AnonymousUserWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FittedBox(
        child: Text(
          "Anonymous User",
          style: TextStyleFontTheme.poppins.copyWith(
            color: Colors.black38,
          ),
          textScaleFactor: 1.5,
        ),
      ),
    );
  }
}

class NotYetPlayedWidget extends StatelessWidget {
  const NotYetPlayedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      child: Text(
        "Never played yet",
        textScaleFactor: 2.5,
        style: TextStyleFontTheme.bangers.copyWith(
          color: Colors.brown,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
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
