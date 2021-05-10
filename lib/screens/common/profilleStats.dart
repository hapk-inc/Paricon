import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final String stats;
  final double value;
  const ProfileStats({Key key, this.stats, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListTile(
        title: Text(
          stats.contains("AVG") ? "$value" : "${value.toInt()}",
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.pink),
          textAlign: TextAlign.center,
        ),
        subtitle: Text(
          stats,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Colors.pink,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}
