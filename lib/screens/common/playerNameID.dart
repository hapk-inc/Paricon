import 'package:flutter/material.dart';
import 'package:paricon/models/profile.dart';

class PlayerNameIdWidget extends StatelessWidget {
  final Profile profile;
  const PlayerNameIdWidget({this.profile, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              profile.name ?? "Someone",
              style: TextStyle(color: Colors.pink, fontSize: 48),
            ),
          ),
          Flexible(
            child: Text(
              /*"ID: " + */ "${profile.userID}",
              style: TextStyle(color: Colors.pink[400], fontSize: 32),
            ),
          )
        ],
      ),
    );
  }
}
