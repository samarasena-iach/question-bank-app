import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question.dart';

class QuestionDatabase {
  static final QuestionDatabase instance = QuestionDatabase._init();

  static Database? _database;

  QuestionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('questions.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionContent TEXT,
        answerContent TEXT,
        category TEXT,
        createdAt TEXT
      )
    ''');
  }

  Future<Question> create(Question question) async {
    final db = await instance.database;

    final id = await db.insert('questions', question.toMap());
    return question.copyWith(id: id);
  }

  Future<List<Question>> readAllQuestions() async {
    final db = await instance.database;

    final result = await db.query('questions', orderBy: 'createdAt DESC');

    return result.map((map) => Question.fromMap(map)).toList();
  }

  Future<int> update(Question question) async {
    final db = await instance.database;
    return db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
