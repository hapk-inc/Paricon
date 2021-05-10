import 'package:flutter/material.dart';
import 'package:paricon/models/stats.dart';
import 'package:paricon/screens/common/profilleStats.dart';

class OverallStatsWidget extends StatelessWidget {
  final Stats stats;
  const OverallStatsWidget({Key key, this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ProfileStats(stats: "GAMES", value: stats.played.toDouble()),
        ProfileStats(
          stats: "WINS",
          value: stats.win.toDouble(),
        ),
        ProfileStats(
          stats: "AVG. SCORE",
          value: stats.avg,
        ),
      ],
    );
  }
}
