import 'package:flutter/material.dart';
import 'package:hku_guesser/game.dart';
import 'package:hku_guesser/game_state.dart';
import 'package:hku_guesser/question_database.dart';
import 'package:hku_guesser/sync_db.dart';

class LoadingPage extends StatelessWidget {
  final String gameMode;
  const LoadingPage({required this.gameMode, super.key});

  Future<List<Question>> _loadQuestion() async {
    final check = await QuestionDatabase.instance.getQuestions();

    if (check.isEmpty) {
      await initailize_question();
    } else {
      await updateQuestion();
    }

    final loaded_questions = await QuestionDatabase.instance.getQuestions();
    loaded_questions.shuffle();
    return loaded_questions;
  }

  Future<List<Question>> _loadDaily() async {
    final question = await getDailyQuestion();
    assert(question != null, "Failed to get daily challenge question");
    return question!;
  }

  @override
  Widget build(BuildContext context) {
    if (this.gameMode == "Daily") {
      return FutureBuilder<List<Question>>(
        future: _loadDaily(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          } else if (snapshot.hasData) {
            return GamePage(gameState: GameState(totalRound: 1, questions: snapshot.data!));
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else {
            return Container(); // Placeholder widget if none of the above conditions are met
          }
        },
      );
    }
    return FutureBuilder<List<Question>>(
      future: _loadQuestion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasData) {
          return GamePage(gameState: GameState(totalRound: 5, questions: snapshot.data!));
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else {
          return Container(); // Placeholder widget if none of the above conditions are met
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      )
    );
    
    
  }

  Widget _buildErrorWidget(String error) {
    return Scaffold(
      body: Center(
        child: Text('Error: $error'),
      )
    );
  }
}