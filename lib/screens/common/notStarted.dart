import 'package:flutter/material.dart';

class NotStartedWidget extends StatelessWidget {
  const NotStartedWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Not yet started",
        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
      ),
    );
  }
}
