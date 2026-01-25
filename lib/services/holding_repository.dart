import 'package:sqflite/sqflite.dart';
import '../models/holding.dart';
import 'database_helper.dart';

class HoldingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Holding holding) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'holdings',
      holding.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Holding>> getAll({bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.query('holdings', orderBy: 'createdAt DESC');
    } else {
      maps = await db.query(
        'holdings',
        where: 'deleted = ?',
        whereArgs: [0],
        orderBy: 'createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Holding.fromMap(maps[i]));
  }

  Future<Holding?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'holdings',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Holding.fromMap(maps.first);
  }

  Future<int> update(Holding holding) async {
    final db = await _dbHelper.database;
    return await db.update(
      'holdings',
      holding.toMap(),
      where: 'id = ?',
      whereArgs: [holding.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final holding = await getById(id);
    if (holding == null) return 0;

    // Soft delete
    final updated = holding.copyWith(
      deleted: true,
      updatedAt: DateTime.now(),
    );
    return await update(updated);
  }

  Future<int> permanentDelete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'holdings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
