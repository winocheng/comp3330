class Question {
  final String id;
  final String jsonText;
  final String imagePath;

  Question({
    required this.id,
    required this.jsonText,
    required this.imagePath,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      jsonText: map['jsonText'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jsonText': jsonText,
      'imagePath': imagePath,
    };
  }
}

class GameState {
  List<Question> questions;
  final int totalRound;
  int totalScore = 0;
  int roundNum = 1;
  int roundScore = 0;
  int remainingTime = 0;
  final int roundTime; // in seconds
  final transitionTime = 10; // in seconds
  bool shuffle = false;

  GameState({
    this.questions = const [],
    required this.totalRound,
    this.roundTime = 60,
  });
}
