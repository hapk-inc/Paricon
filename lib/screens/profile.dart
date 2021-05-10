import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/authProvider.dart';
import 'package:paricon/providers/packagInfoProvider.dart';
import 'package:paricon/providers/playerProvider.dart';

import 'common/notStarted.dart';
import 'common/overallStats.dart';
import 'common/playerNameID.dart';

class ProfileScreen extends StatelessWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
        child: ProfileScreen(),
        name: '/profile',
        key: ValueKey('profile'),
      );

  Widget errorContainer(error, stackTrace) {
    print("Error is " + error.toString());
    print("Error is " + stackTrace.toString());
    return Center(
      child: Text(
        "Something Wrong",
        style: TextStyle(fontFamily: "Poppins", fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.pink[200],
        appBar: AppBar(
          backgroundColor: Colors.pink,
          actions: [SignOutButton()],
        ),
        body: Consumer(
          builder: (context, watch, child) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: watch(profileProvider).when(
              data: (_player) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        PlayerIconWidget(),
                        PlayerNameIdWidget(profile: _player),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 60,
                      child: TabBar(
                        labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.pink,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins'),
                        tabs: const ['Easy', 'Medium', 'Hard']
                            .map(
                              (e) => Tab(
                                child: Text(e),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: TabBarView(
                      children: _player.stats
                          .map((stats) => stats.played == 0
                              ? NotStartedWidget()
                              : OverallStatsWidget(stats: stats))
                          .toList(growable: false),
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                    ),
                  ),
                  Flexible(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: watch(packageInfoProvider).maybeWhen(
                          orElse: () => CircularProgressIndicator(),
                          data: (value) => Text(
                            "Version : " + value.version,
                            style: TextStyle(color: Colors.pink),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: errorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerIconWidget extends StatelessWidget {
  const PlayerIconWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Container(
        child: Center(
          child: FittedBox(
            child: const Icon(
              Icons.person_rounded,
              size: 128,
              color: Colors.pink,
            ),
          ),
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.read(signOutProvider),
      child: Text(
        "SIGN OUT",
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(letterSpacing: 5, fontSize: 16),
      ),
    );
  }
}
