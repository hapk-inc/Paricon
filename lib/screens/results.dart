import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/boardProvider.dart';
import 'package:paricon/providers/prevStatsNotifier.dart';
import 'package:paricon/providers/roomIDProvider.dart';

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
                            style: TextStyle(
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
                              headingTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    letterSpacing: 5,
                                  ),
                              dataTextStyle:
                                  Theme.of(context).textTheme.bodyText1,
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
                            style: TextStyle(
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
            [/*"PLAY AGAIN",*/ "EXIT GAME"].map(
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
}
