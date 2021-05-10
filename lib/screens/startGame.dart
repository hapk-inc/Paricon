import 'package:flutter/material.dart';

import 'enterRoomCode.dart';
import 'setGame.dart';

class StartGame extends StatelessWidget {
  static MaterialPage get toMaterialPage => MaterialPage(
      child: StartGame(), key: ValueKey('startGame'), name: '/startGame');
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo[800],
          //toolbarHeight: 100,
          bottom: TabBar(
            labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
            tabs: [
              Tab(text: "Create Game"),
              Tab(text: "Join Game"),
            ],
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
              color: Colors.yellow,
              width: 4,
            )),
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
}
