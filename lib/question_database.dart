import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hku_guesser/game_state.dart';

class QuestionDatabase {
  static final QuestionDatabase instance = QuestionDatabase._init();
  static Database? _database;

  QuestionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('questions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jsonText TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertQuestion(String jsonText, String imagePath) async {
    final db = await instance.database;
    return await db.insert(
      'questions',
      {'jsonText': jsonText, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Question>> getQuestions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('questions');
    return List<Question>.from(
      maps.map((map) => Question.fromMap(map)),
    );
  }
}
