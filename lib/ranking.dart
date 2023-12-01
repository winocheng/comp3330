import 'package:flutter/material.dart';
import 'package:hku_guesser/constants.dart';

class RankingPage extends StatefulWidget {
  final String? name;
  final int? score;
  const RankingPage({Key? key, this.name, this.score}) : super(key: key);

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  static const general = 0, daily = 1;
  var _rankingType = general;
  late List<LeaderboardData> _leaderboardScores;

  void getLeaderboardScores(int type) async {
    //TODO: link to database
    final leaderboardScores = [
      LeaderboardData(name: "Bot1", score: 1000),
      LeaderboardData(name: "Bot2", score: 10000)
    ];

    if (widget.name != null && widget.score != null) {
      leaderboardScores
          .add(LeaderboardData(name: widget.name!, score: widget.score!));
    }
    leaderboardScores.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      _rankingType = type;
      _leaderboardScores = leaderboardScores;
    });
  }

  @override
  void initState() {
    super.initState();
    getLeaderboardScores(_rankingType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
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
              style: TextStyle(
                color: highlightColor1,
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
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
                      rows: List.generate(_leaderboardScores.length, (index) {
                        final leaderboard = _leaderboardScores[index];
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
            ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_sharp),
              label: "General",
            ),
            BottomNavigationBarItem(
              icon: Stack(alignment: Alignment(0, 0.5), children: [
                Icon(Icons.calendar_today_rounded),
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

class LeaderboardData {
  final String name;
  final int score;

  LeaderboardData({
    required this.name,
    required this.score,
  });

  factory LeaderboardData.fromJson(Map json, bool isUser) {
    return LeaderboardData(
      name: isUser ? 'You' : json['name'],
      score: json['score'],
    );
  }
}
