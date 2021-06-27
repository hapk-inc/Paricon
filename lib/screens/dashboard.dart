import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:paricon/screens/setPractice.dart';

import 'common/paddingTheme.dart';
import 'providers/authProvider.dart';

import 'startGame.dart';

import 'allPlayers.dart';
import 'common/buttonStyleTheme.dart';
import 'common/snackBarTheme.dart';
import 'common/textTheme.dart';
import 'profile.dart';
import 'providers/pageProvider.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({Key? key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: Dashboard(),
        key: ValueKey('dashBoard'),
        name: '/dashboard',
      );

  List<Widget> get buttonList => const [
        DashButtons(
          btnColor: Colors.red,
          title: "Play Local Game",
          subtitle: "Play in One Phone",
          isLeftAligned: true,
        ),
        Spacer(),
        DashButtons(
          btnColor: Colors.indigo,
          title: "Play Online",
          subtitle: "Play with your friends",
          isLeftAligned: false,
        ),
        Spacer(),
        DashButtons(
          btnColor: Colors.green,
          title: "Friends and Strangers",
          subtitle: "Check out other players",
          isLeftAligned: true,
        ),
      ];

  @override
  Widget build(BuildContext context, ScopedReader watch) => Scaffold(
        backgroundColor: Colors.purple[100],
        body: SafeArea(
          minimum: PaddingTheme.all8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DashboardHeader(),
              Spacer(),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? Column(children: buttonList)
                            : Row(children: buttonList),
                  ),
                ),
                flex: 7,
              ),
              //Spacer()
            ],
          ),
        ),
      );
}

class DashButtons extends StatelessWidget {
  final String? title, subtitle;
  final Color? btnColor;
  final bool? isLeftAligned;
  const DashButtons(
      {Key? key, this.title, this.subtitle, this.btnColor, this.isLeftAligned})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 6,
      child: ElevatedButton(
        style: ButtonStyleTheme.buildDashboardButtonStyle(btnColor: btnColor),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: FittedBox(
                  child: Text(
                    title!,
                    style: TextStyleFontTheme.poppins.copyWith(fontSize: 24),
                    textScaleFactor: 1,
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle!,
                    style:
                        TextStyleFontTheme.luckiestGuy.copyWith(fontSize: 36),
                    maxLines: 3,
                    //textScaleFactor: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          final analytics = context.read(firebaseAnalyticsProvider);
          switch (title!) {
            case "Play Online":
              {
                analytics.setCurrentScreen(screenName: "play_online_screen");
                context.read(pageProvider).addNext(StartGame.toMaterialPage);
                break;
              }
            case "Play Local Game":
              context.read(pageProvider).addNext(SetPractice.toMaterialPage);
              break;
            case "Friends and Strangers":
              context.read(pageProvider).addNext(AllPlayers.toMaterialPage);
              break;
            default:
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBarThemeStyle.comingSoon());
          }
        },
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Image.asset(
                'assets/title_purple.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Flexible(
            child: IconButton(
              constraints: BoxConstraints.expand(),
              color: Colors.purple[800],
              splashRadius: 72,
              iconSize: 128,
              highlightColor: Colors.purple[200],
              icon: FittedBox(
                child: Icon(
                  Icons.person,
                  //size: 96,
                ),
              ),
              alignment: Alignment.center,
              onPressed: () => context
                  .read(pageProvider)
                  .addNext(ProfileScreen.toMaterialPage),
            ),
          )
        ],
      ),
    );
  }
}
