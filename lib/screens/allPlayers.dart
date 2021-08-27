import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/profile.dart';

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
      initialIndex: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            color: Colors.white70,
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.black26,
                    unselectedLabelStyle:
                        TextStyleFontTheme.poppins.copyWith(fontSize: 16),
                    labelStyle:
                        TextStyleFontTheme.poppins.copyWith(fontSize: 24),
                    tabs: levels
                        .map(
                          (e) => Tab(text: e.toUpperCase()),
                        )
                        .toList(growable: false),
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
      watch(allUsersProvider(level)).when(
        data: (value) => value.isEmpty
            ? Container(
                alignment: Alignment.center,
                child: Text(
                  "No Data..",
                  style: TextStyleFontTheme.bangers.copyWith(fontSize: 24),
                ),
              )
            : UserList(users: value, level: level),
        loading: () => Center(child: CircularProgressTheme.pinkIndicator),
        error: (error, stackTrace) {
          return CircularProgressIndicator();
        },
      );
}

class UserList extends StatelessWidget {
  final List<Profile> users;
  final String level;
  const UserList({Key? key, required this.users, required this.level})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final profile = users[index];

          final stats = users[index].stats![levels.indexOf(level)];
          int randomColor = Random().nextInt(Colors.primaries.length);
          final tileColor = Colors.primaries[randomColor];
          return LimitedBox(
            maxHeight: MediaQuery.of(context).size.height *
                (index == 0 ? 0.15 : 0.125),
            child: Card(
              elevation: 8,
              //color: index == 0 ? tileColor.shade50 : tileColor.shade400,
              color: tileColor.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: tileColor.shade600, width: 4)),
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
                                strSubTitle: "Wins",
                              ),
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
      );
}

class TitleSubTitle extends StatelessWidget {
  final String strTitle;
  final String strSubTitle;

  const TitleSubTitle(
      {Key? key, required this.strTitle, required this.strSubTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
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
