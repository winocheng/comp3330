import 'package:path/path.dart';
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
    bool databaseExists = await databaseFactory.databaseExists(path);

    // If the database file exists, delete it
    if (databaseExists) {
      await deleteDatabase(path);
      // print("Deleted");
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions(
        id TEXT PRIMARY KEY,
        jsonText TEXT,
        imagePath TEXT NULL
      )
    ''');
    await db.execute('CREATE TABLE daily(id TEXT PRIMARY KEY, date TEXT)');
  }

  Future<int> insertQuestion(String id, String jsonText, String? imagePath) async {
    final db = await instance.database;
    return await db.insert(
      'questions',
      {'id': id, 'jsonText': jsonText, 'imagePath': imagePath},
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

  Future<List<Map<String, Object?>>> doQuery(String sql) async {
    final db = await instance.database;
    return db.rawQuery(sql);
  }
}
