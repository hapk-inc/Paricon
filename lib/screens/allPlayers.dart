import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/circularProgressTheme.dart';
import 'common/paddingTheme.dart';
import 'common/textTheme.dart';
import 'providers/playerProvider.dart';

const List<String> levels = ["easy", "medium", "hard"];

class AllPlayers extends StatelessWidget {
  const AllPlayers({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: AllPlayers(),
        key: ValueKey('allPlayers'),
        name: '/allPlayers',
      );

  @override
  Widget build(BuildContext context) {
    TabController? _controller;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white70,
        body: SafeArea(
          child: Container(
            //color: Colors.green[50],
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: TabBar(
                    tabs: levels
                        .map(
                          (e) => Tab(
                            child: Container(
                              padding: PaddingTheme.all4,
                              constraints: BoxConstraints.expand(),
                              child: FittedBox(
                                child: Text(
                                  e.toUpperCase(),
                                  style: TextStyleFontTheme.poppins,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Colors.indigo[50]!,
                        width: 2.5,
                      ),
                    ),
                    onTap: (value) => FocusScope.of(context).unfocus(),
                  ),
                ),
                Flexible(
                  flex: 9,
                  child: Padding(
                    padding: PaddingTheme.all8,
                    child: TabBarView(
                      children: levels
                          .map((e) => LevelPlayers(level: e))
                          .toList(growable: false),
                      controller: _controller,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LevelPlayers extends ConsumerWidget {
  final String level;

  const LevelPlayers({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) =>
      watch(allPlayerProvider(level)).when(
        data: (value) => value == null
            ? Container(
                alignment: Alignment.center,
                child: Text(
                  "No Data..",
                  style: TextStyleFontTheme.bangers.copyWith(fontSize: 24),
                ),
              )
            : ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final profile = value[index];
                  final stats = value[index].stats![levels.indexOf(level)];
                  final tileColor = Colors
                      .primaries[Random().nextInt(Colors.primaries.length)];
                  return LimitedBox(
                    maxHeight: MediaQuery.of(context).size.height *
                        (index == 0 ? 0.2 : 0.125),
                    child: Card(
                      elevation: 8,
                      color:
                          index == 0 ? tileColor.shade50 : tileColor.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: TitleSubTitle(
                                  strTitle: profile.name,
                                  strSubTitle: "${profile.userID}",
                                ),
                                flex: 7,
                              ),
                              Flexible(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TitleSubTitle(
                                          strTitle: "${stats.played}",
                                          strSubTitle: "Games"),
                                    ),
                                    Flexible(
                                      child: TitleSubTitle(
                                          strTitle: "${stats.win}",
                                          strSubTitle: "Wins"),
                                    ),
                                    Flexible(
                                      child: TitleSubTitle(
                                          strTitle: "${stats.avg}",
                                          strSubTitle: "Avg. Score"),
                                    ),
                                  ],
                                ),
                                flex: 13,
                              )
                            ],
                          ),
                          /*    if (index == 0)
                            Positioned(
                              right: -5,
                              top: -5,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                child: Lottie.asset(
                                  'assets/lottie/ribbon.json',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),*/
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => Center(child: CircularProgressTheme.pinkIndicator),
        error: (error, stackTrace) {
          //print(error);
          //print(stackTrace);
          return CircularProgressIndicator();
        },
      );
}

class TitleSubTitle extends StatelessWidget {
  final String strTitle;
  final String strSubTitle;

  const TitleSubTitle(
      {Key? key, required this.strTitle, required this.strSubTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListTile(
        title: AutoSizeText(
          strTitle,
          style: TextStyleFontTheme.luckiestGuy.copyWith(fontSize: 24),
          maxLines: 1,
        ),
        subtitle: AutoSizeText(
          strSubTitle,
          maxLines: 1,
        ),
      ),
    );
  }
}
