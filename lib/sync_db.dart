import 'dart:convert';

import 'package:hku_guesser/constants.dart';
import 'package:hku_guesser/image.dart';
import 'package:hku_guesser/question_database.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<bool> checkServerConnection(String serverUrl) async {
  try {
    final response = await http.get(Uri.parse(serverUrl))
    .timeout(const Duration(seconds: 2));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<String?> downloadImage(String qid) async {
  try {
    final response = await http.get(Uri.parse("$serverIP/image/$qid"));
    return base64Encode(response.bodyBytes);
  } catch (e) {
    print("caught error while retrieving data: $e");
    return null;
  }


}

Future<void> initLocalData(int n) async {
  QuestionDatabase.instance.insertQuestion(
    "6558b6fe5ca77f50e641484e",
        jsonEncode({
          "x-coordinate": 1250.6396965865638,
          "y-coordinate": 2192.9494311002054,
          "floor": "G"
        }),
  await saveImageToStorageFromAssets('assets/images/image1.jpg', n));
  n += 1;
  QuestionDatabase.instance.insertQuestion(
    "6558b6fe5ca77f50e641484f",
        jsonEncode({
          "x-coordinate": 756.0008071041827,
          "y-coordinate": 1779.2338975242087,
          "floor": "G"
        }),
  await saveImageToStorageFromAssets('assets/images/image2.jpg', n));
  n += 1;
  QuestionDatabase.instance.insertQuestion(
    "6558b6fe5ca77f50e6414850",
        jsonEncode({
          "x-coordinate": 1079.0698739572947,
          "y-coordinate": 1761.3012672814534,
          "floor": "G"
        }),
  await saveImageToStorageFromAssets('assets/images/image3.jpg', n));
  n += 1;
  QuestionDatabase.instance.insertQuestion(
    "6558b6fe5ca77f50e6414851",
        jsonEncode({
          "x-coordinate": 1316.161512420328,
          "y-coordinate": 1573.6029707893044,
          "floor": "G"
        }),
  await saveImageToStorageFromAssets('assets/images/image4.jpg', n));
  n += 1;
  QuestionDatabase.instance.insertQuestion(
    "6558b6fe5ca77f50e6414852",
        jsonEncode({
          "x-coordinate": 1838.7289309565551,
          "y-coordinate": 1693.0511053619784,
          "floor": "2"
        }),
  await saveImageToStorageFromAssets('assets/images/image5.jpg', n));
}

Future<void> initailize_question({var n = 1}) async {
  bool isConnected = await checkServerConnection(serverIP);
  if (isConnected) {
    try {
      final response = await http.get(Uri.parse("$serverIP/sync_question"));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        for (var question in jsonData) {
          final image_byte = await downloadImage(question["id"]);
          assert(image_byte != null, 'failed to get image');
          await QuestionDatabase.instance.insertQuestion(question["id"],
          jsonEncode({
            "x-coordinate": question["x"],
            "y-coordinate": question["y"],
            "floor": question["floor"]
          }),
          await saveImageToStorageFromBytes(image_byte!, question["id"]));
        }
      }
    } 
    catch (e) {
      print(e);
      await initLocalData(n);
    }
  } else {
    await initLocalData(n);
  }
  }

Future<void> updateQuestion() async {
  List<Map> result = await QuestionDatabase.instance.doQuery("SELECT MAX(id) AS max_id FROM questions");
  bool isConnected = await checkServerConnection(serverIP);

  if (isConnected) {
    try {
      final response = await http.get(Uri.parse("$serverIP/sync_question?after=${result[0]['max_id']}"));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        for (var question in jsonData) {
          final image_byte = await downloadImage(question["id"]);
          assert(image_byte != null, 'failed to get image');
          await QuestionDatabase.instance.insertQuestion(question["id"],
          jsonEncode({
            "x-coordinate": question["x"],
            "y-coordinate": question["y"],
            "floor": question["floor"]
          }),
          await saveImageToStorageFromBytes(image_byte!, question["id"]));
        }
      }
    }
    catch (e) {
      print(e);
    }

  }

}
