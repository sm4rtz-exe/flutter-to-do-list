import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/models/todo.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tableName = "todos";
  final String _id = "id";
  final String _title = "title";
  final String _finished = "finished";
  final String _dateTimeCreated = "dateTimeCreated";
  final String _deadLine = "deadLine";
  final String _dateClosed = "dateClosed";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      onCreate: (db, version) => {
        db.execute('''CREATE TABLE $_tableName(
            $_id INTEGER PRIMARY KEY AUTOINCREMENT, 
            $_title TEXT NOT NULL, description TEXT, 
            $_finished INTEGER NOT NULL, 
            $_dateTimeCreated TEXT NOT NULL, 
            $_deadLine TEXT, 
            $_dateClosed Text
            )'''),
      },
    );
    return database;
  }

  Future<void> addTask(Todo todo) async {
    final db = await database;
    await db.insert(_tableName, todo.toMap());
  }

  Future<List<Todo>> getTasks() async {
    final db = await database;
    final data = await db.query(_tableName);
    return data.map((e) {
      return Todo.fromMap(e);
    }).toList();
  }
}
