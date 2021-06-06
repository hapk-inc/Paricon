import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/paddingTheme.dart';
import 'common/statsValue.dart';
import 'common/textTheme.dart';
import 'providers/gameIconProvider.dart';
import 'providers/onlineBoardProvider.dart';
import 'providers/prevStatsNotifier.dart';
import 'providers/roomIDProvider.dart';

class GameResults extends StatelessWidget {
  const GameResults({Key? key}) : super(key: key);
  static MaterialPage toMaterialPage() => MaterialPage(
        child: GameResults(),
        name: '/gameResults',
        key: ValueKey('gameResults'),
      );
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read(gameIconProvider!);
    final onlineNotifier = context.read(onlineBoardNotifier);
    return Scaffold(
      backgroundColor:
          gameProvider.iconColor(onlineNotifier.sortByPoints.first.color),
      body: WillPopScope(
        onWillPop: () async {
          context.read(idNotifier.notifier).empty();
          context.read(onlineBoardNotifier).dispose();
          return true;
        },
        child: SafeArea(
          //minimum: PaddingTheme.all16,
          child: Padding(
            padding: PaddingTheme.all16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "Results",
                            style: TextStyleFontTheme.luckiestGuy.copyWith(
                              fontSize: 48,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      ShadedLine(),
                    ],
                  ),
                ),
                PlayerTable(),
                Flexible(
                  child: Row(
                    children: [
                      ShadedLine(),
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "YOUR RESULTS",
                            style: TextStyleFontTheme.luckiestGuy.copyWith(
                              fontSize: 48,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MyResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyResults extends ConsumerWidget {
  const MyResults({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final prevStats = watch(prevStatsProvider);

    return Flexible(
      flex: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StatsValueWidget(
            value: prevStats.level,
            header: "LEVEL",
            color: Colors.white70,
          ),
          StatsValueWidget(
            value: prevStats.pts,
            header: "POINTS",
            color: Colors.white70,
          ),
          StatsValueWidget(
            value: prevStats.avg,
            header: "AVG. SCORE",
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}

class PlayerTable extends StatelessWidget {
  const PlayerTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameiCon = context.read(gameIconProvider!);
    final notifier = context.read(onlineBoardNotifier);
    final players = notifier.sortByPoints;
    return Flexible(
      fit: FlexFit.tight,
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(6),
            2: FlexColumnWidth(2),
          },
          children: <TableRow>[
                TableRow(
                  //decoration: BoxDecoration(border: BoxBorder()),
                  children: [
                    TableHeader(title: "Name"),
                    TableHeader(title: "Icons"),
                    TableHeader(title: "Points"),
                  ],
                )
              ] +
              players
                  .map(
                    (e) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            e.name!,
                            style: TextStyleFontTheme.luckiestGuy
                                .copyWith(color: Colors.white70, fontSize: 72),
                            maxLines: 1,
                            minFontSize: 32,
                            maxFontSize: 48,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 2.0,
                            //alignment: WrapAlignment.center,
                            //crossAxisAlignment: WrapCrossAlignment.start,
                            children: notifier
                                .coloredIcons(e.color!)
                                .map(
                                  (e) => Icon(
                                    gameiCon.gameIcon(e.iconCode),
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AutoSizeText(
                            e.pts.toString(),
                            style: TextStyleFontTheme.luckiestGuy.copyWith(
                              fontSize: 48,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            minFontSize: 36,
                            maxFontSize: 72,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  final String title;
  const TableHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: TextStyleFontTheme.luckiestGuy
              .copyWith(fontSize: 20, color: Colors.white60),
        ),
      );
}

class ShadedLine extends StatelessWidget {
  const ShadedLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white70,
            Colors.white54,
            Colors.white30,
            Colors.white30,
            Colors.white12,
            Colors.transparent
          ],
        ).createShader(bounds),
        child: Divider(
          color: Colors.white60,
          thickness: 4,
          indent: 16,
        ),
      ),
    );
  }
}

/*
class GameResults extends StatelessWidget {
  static MaterialPage toMaterialPage() => MaterialPage(
        child: GameResults(),
        name: '/gameResults',
        key: ValueKey('gameResults'),
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          context.read(idNotifier.notifier).empty();
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.blue[800],
          body: SafeArea(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Spacer(),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Text(
                            "RESULTS",
                            style: TextStyleFontTheme.poppins.copyWith(
                                fontSize: 32,
                                letterSpacing: 20,
                                color: Colors.blue[300]),
                          ),
                        ),
                      ),
                      ShadedLine()
                    ],
                  ),
                ),
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Consumer(
                      builder: (BuildContext context,
                          T Function<T>(ProviderBase<Object, T>) watch,
                          Widget child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: watch(allBoardPlayersProvider).when(
                            data: (_allPlayers) => DataTable(
                              headingTextStyle: TextStyleFontTheme.poppins
                                  .copyWith(
                                      letterSpacing: 5,
                                      color: Colors.blue[100]),
                              dataTextStyle: TextStyleFontTheme.poppins,
                              columns: <DataColumn>[
                                //DataColumn(label: const Text('No')),
                                DataColumn(
                                  label: const Text('Name'),
                                ),
                                DataColumn(
                                  label: const Text('Points'),
                                  numeric: true,
                                ),
                              ],
                              rows: List.from(
                                _allPlayers.map(
                                  (player) => DataRow(
                                    cells: <DataCell>[
                                      //DataCell(Text('${player.playerNo}')),
                                      DataCell(Text(player.name)),
                                      DataCell(Text('${player.pts}')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            loading: () => Container(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "YOUR SCORE",
                            style: TextStyleFontTheme.poppins.copyWith(
                                letterSpacing: 10, color: Colors.blue[300]),
                          ),
                        ),
                      ),
                      ShadedLine(),
                    ],
                  ),
                ),
                YourResults(),
                BottomButtons(),
                Spacer(),
              ],
            ),
          ),
        ),
      );
}

class ShadedLine extends StatelessWidget {
  const ShadedLine({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white54,
              Colors.white30,
              Colors.white30,
              Colors.white12,
              Colors.white12,
              Colors.transparent
            ]).createShader(bounds),
        child: Divider(
          color: Colors.white60,
          thickness: 2,
          indent: 16,
        ),
      ),
    );
  }
}

class YourResults extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final prevStats = watch(prevStatsProvider);
    return Flexible(
      fit: FlexFit.tight,
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (prevStats.isWinner ?? true)
              Flexible(
                child: FittedBox(
                  child: Text(
                    "Congratulations",
                    textScaleFactor: 1.25,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[100], letterSpacing: 2),
                  ),
                ),
              ),
            Spacer(),
            Flexible(
              flex: 3,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    YourStatsWidget(
                        title: "LEVEL", value: prevStats.level ?? "Easy"),
                    YourStatsWidget(
                        title: "POINTS", value: prevStats.pts ?? "0"),
                    YourStatsWidget(
                        title: "AVG SCORE", value: prevStats.avg ?? "0"),
                    //YourStatsWidget(title: "RANK", value: "4"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class YourStatsWidget extends StatelessWidget {
  final String title;
  final value;
  const YourStatsWidget({Key key, this.title, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          margin: EdgeInsets.only(top: title.contains("POINTS") ? 12 : 0),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  value.toString(),
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.blue[200]),
                ),
              ),
              SizedBox(height: 10),
              FittedBox(
                child: Text(
                  title,
                  textScaleFactor: 0.75,
                  style: TextStyle(color: Colors.blue[200]),
                ),
              )
            ],
          ),
        ),
      );
}

class BottomButtons extends StatelessWidget {
  const BottomButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.from(
            [*/ /*"PLAY AGAIN",*/ /* "EXIT GAME"].map(
              (title) => Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.9,
                  child: Consumer(
                    builder: (context, watch, child) => ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(8.0),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue[200]),
                        elevation: MaterialStateProperty.all<double>(16.0),
                      ),
                      onPressed: () async {
                        context.read(idNotifier.notifier).empty();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            title,
                            style: TextStyle(
                                color: Colors.blue[600], letterSpacing: 5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}*/
