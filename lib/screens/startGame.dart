import 'package:flutter/material.dart';
import 'package:paricon/screens/common/textTheme.dart';
import 'package:paricon/screens/enterRoomCode.dart';
import 'package:paricon/screens/setGame.dart';

import 'common/paddingTheme.dart';

class StartGame extends StatelessWidget {
  const StartGame({Key key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
      child: StartGame(), key: ValueKey('startGame'), name: '/startGame');

  @override
  Widget build(BuildContext context) {
    TabController _controller;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.indigo,
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: TabBar(
                  tabs: const ["Create Game", "Join Game"]
                      .map(
                        (e) => Tab(
                          child: Container(
                            padding: PaddingTheme.all4,
                            constraints: BoxConstraints.expand(),
                            child: FittedBox(
                              child: Text(
                                e,
                                style: TextStyleFontTheme.reggaeOne,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: Colors.indigo[50],
                      width: 5,
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
                    children: [
                      SetGame(isGameOnline: true),
                      EnterRoomCode(),
                    ],
                    controller: _controller,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*class StartGame extends StatelessWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
      child: StartGame(), key: ValueKey('startGame'), name: '/startGame');
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo[800],
          //toolbarHeight: MediaQuery.of(context).size,
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
            tabs: [
              Tab(text: "Create Game"),
              Tab(text: "Join Game"),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Colors.yellow,
                width: 4,
              ),
            ),
            onTap: (value) => FocusScope.of(context).unfocus(),
          ),
        ),
        body: TabBarView(
          children: [SetGame(isGameOnline: true), EnterRoomCode()],
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}*/
