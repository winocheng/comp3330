import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/sync_score.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RankingPage extends StatefulWidget {
  final int gameType;
  final String? name;
  final int? score;
  const RankingPage({Key? key, this.gameType = 0, this.name, this.score})
      : super(key: key);

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  static const general = 0, daily = 1;
  late int _rankingType;
  List<LeaderboardData>? _leaderboardScores;

  List<LeaderboardData> showLeaderBoardScores(List<LeaderboardData>? scores) {
    if (scores == null) {
      Fluttertoast.showToast(msg: "Error Retrieving Leaderboard");
      return [];
    } else {
      scores.sort((a, b) => b.score.compareTo(a.score));
      return scores;
    }
  }

  void getLeaderboardScores(int type) async {
    getRanking(type, widget.name).then((value) {
      setState(() {
        _rankingType = type;
        _leaderboardScores = showLeaderBoardScores(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _rankingType = widget.gameType;
    if (widget.name != null && widget.score != null) {
      uploadRanking(widget.gameType, widget.name!, widget.score!).then((value) {
        setState(() {
          _leaderboardScores = showLeaderBoardScores(value);
        });
      });
    } else {
      getLeaderboardScores(_rankingType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: mainColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              switch (_rankingType) {
                general => "Leaderboard",
                daily => "Today's leaderboard",
                _ => "Leaderboard"
              },
              style: const TextStyle(
                color: highlightColor1,
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 20),
            _leaderboardScores != null
                ? Leaderboard(leaderboardScores: _leaderboardScores!)
                : const CircularProgressIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _rankingType,
          onTap: getLeaderboardScores,
          iconSize: 36.0,
          selectedItemColor: highlightColor1,
          unselectedItemColor: highlightColor2,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_sharp),
              label: "General",
            ),
            BottomNavigationBarItem(
              icon: Stack(alignment: const Alignment(0, 0.5), children: [
                const Icon(Icons.calendar_today_rounded),
                Text(
                  DateTime.now().day.toString(),
                  style: TextStyle(
                    color: _rankingType == daily
                        ? highlightColor1
                        : highlightColor2,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ]),
              label: "Daily",
            ),
          ]),
    );
  }
}

class Leaderboard extends StatelessWidget {
  final List<LeaderboardData> leaderboardScores;
  const Leaderboard({Key? key, required this.leaderboardScores})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 500,
      child: SingleChildScrollView(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.black),
          child: DataTable(
              columns: const [
                DataColumn(
                  label: Text('Rank'),
                ),
                DataColumn(
                  label: Text('Name'),
                ),
                DataColumn(
                  label: Text('Score'),
                ),
              ],
              rows: List.generate(leaderboardScores.length, (index) {
                final leaderboard = leaderboardScores[index];
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(
                      leaderboard.name,
                      style: TextStyle(
                        color: leaderboard.name == 'You'
                            ? highlightColor2
                            : Colors.black,
                      ),
                    )),
                    DataCell(Text(leaderboard.score.toString())),
                  ],
                );
              })),
        ),
      ),
    );
  }
}
