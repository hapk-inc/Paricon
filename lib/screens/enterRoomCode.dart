import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/enumFiles.dart';
import 'package:paricon/screens/common/textTheme.dart';
import 'package:paricon/screens/providers/authProvider.dart';

import 'common/snackBarTheme.dart';
import 'gameRoom.dart';
import 'providers/pageProvider.dart';

//import 'providers/roomNotifierProvider.dart';
import 'providers/roomProvider.dart';

class EnterRoomCode extends StatelessWidget {
  const EnterRoomCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    void _onPressed(String text) async {
      if (text.isNotEmpty && text.length == 6) {
        //context.read(roomNotifierProvider).loading = true;
        await context.read(roomCheckProvider!(text).future).then(
          (value) async {
            if (value is String) {
              await context.read(joinRoomProvider.future);
              final analytics = context.read(firebaseAnalyticsProvider);
              analytics.setCurrentScreen(screenName: "game_room_screen");
              context
                  .read(pageProvider)
                  .replace(GameRoom.toMaterialPage(id: value));
            } else {
              final status = value as RoomStatus;
              String msg = "";
              switch (status) {
                case RoomStatus.houseFull:
                  msg = "Room is full already";
                  break;
                case RoomStatus.notExists:
                  msg = "Room not exists";
                  break;
                case RoomStatus.alreadyStarted:
                  msg = "Game already Started";
                  break;
                case RoomStatus.duplicateCode:
                  msg = "Try with some other code";
                  break;
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBarThemeStyle.roomCodeError(msg));
            }
          },
        );
      } else
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBarThemeStyle.roomCodeError("Enter valid roomCode"));
      // context.read(roomNotifierProvider).loading = false;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          autofocus: true,
          controller: _controller,
          style: TextStyleFontTheme.poppins.copyWith(
            color: Colors.white54,
            fontSize: MediaQuery.of(context).size.height * 0.05,
            letterSpacing: 5,
          ),
          cursorColor: Colors.white54,
          keyboardType:
              TextInputType.numberWithOptions(decimal: false, signed: false),
          onEditingComplete: () => _onPressed(_controller.text),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            labelText: 'Enter Room Code',
            labelStyle: TextStyleFontTheme.poppins.copyWith(
              fontSize: 24,
              letterSpacing: 0.5,
              color: Colors.white60,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Colors.white38,
                width: 4,
              ),
            ),
            suffixIcon: IconButton(
              color: Colors.white70,
              iconSize: 36,
              onPressed: () => _onPressed(_controller.text),
              icon: FittedBox(
                child: Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
