import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kakeibo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFile = path.join(dbPath, filePath);

    return await openDatabase(
      dbFile,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT,
        note TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        remoteId TEXT,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Holdings table
    await db.execute('''
      CREATE TABLE holdings (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        buyPrice REAL,
        buyDate TEXT,
        note TEXT,
        remoteId TEXT,
        deleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
    await db.execute('CREATE INDEX idx_expenses_deleted ON expenses(deleted)');
    await db.execute('CREATE INDEX idx_holdings_deleted ON holdings(deleted)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
