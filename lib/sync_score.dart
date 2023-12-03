import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hku_guesser/constants.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class LeaderboardData {
  final String name;
  final int score;

  LeaderboardData({
    required this.name,
    required this.score,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json, bool isUser) {
    return LeaderboardData(
      name: isUser ? 'You' : json['name'],
      score: json['score'],
    );
  }
}

Future<bool> checkServerConnection(String serverUrl) async {
  try {
    final response = await http
        .get(Uri.parse(serverUrl))
        .timeout(const Duration(seconds: 2));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<List<LeaderboardData>?> getRanking(int scoreType, String? name) async {
  bool isConnected = await checkServerConnection(serverIP);
  if (isConnected) {
    try {
      var scoreTypeStr = scoreType == 0 ? 'general' : 'daily';
      final response =
          await http.get(Uri.parse("$serverIP/score/$scoreTypeStr"));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final leaderboardScores = jsonData
            .map((item) => LeaderboardData.fromJson(item, item['name'] == name))
            .toList();
        return leaderboardScores;
      }
    } catch (e) {
      // print(e);
    }
  }
  Fluttertoast.showToast(msg: "Error Connecting to Server");
  return null;
}

Future<List<LeaderboardData>?> uploadRanking(
    int scoreType, String name, int score) async {
  bool isConnected = await checkServerConnection(serverIP);
  if (isConnected) {
    final Map<String, dynamic> data = {
      'score_type': scoreType,
      'name': name,
      'score': score,
    };
    try {
      final response = await http.post(Uri.parse("$serverIP/score"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Successfully Uploaded Score");
        return getRanking(scoreType, name);
      } else {
        Fluttertoast.showToast(msg: "Error Uploading Score");
      }
    } on SocketException {
      Fluttertoast.showToast(msg: "Error Connecting to Server");
    } catch (e) {
      // print(e);
    }
  }

  return null;
}
