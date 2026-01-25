import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import 'database_helper.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getAll({bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.query('expenses', orderBy: 'date DESC, createdAt DESC');
    } else {
      maps = await db.query(
        'expenses',
        where: 'deleted = ?',
        whereArgs: [0],
        orderBy: 'date DESC, createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getByDateRange(DateTime start, DateTime end, {bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC, createdAt DESC',
      );
    } else {
      maps = await db.query(
        'expenses',
        where: 'date >= ? AND date <= ? AND deleted = ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String(), 0],
        orderBy: 'date DESC, createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getByCategory(String category, {bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.query(
        'expenses',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC, createdAt DESC',
      );
    } else {
      maps = await db.query(
        'expenses',
        where: 'category = ? AND deleted = ?',
        whereArgs: [category, 0],
        orderBy: 'date DESC, createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> search(String query, {bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final searchPattern = '%$query%';
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.query(
        'expenses',
        where: 'note LIKE ? OR category LIKE ?',
        whereArgs: [searchPattern, searchPattern],
        orderBy: 'date DESC, createdAt DESC',
      );
    } else {
      maps = await db.query(
        'expenses',
        where: '(note LIKE ? OR category LIKE ?) AND deleted = ?',
        whereArgs: [searchPattern, searchPattern, 0],
        orderBy: 'date DESC, createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Expense?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<int> update(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final expense = await getById(id);
    if (expense == null) return 0;

    // Soft delete
    final updated = expense.copyWith(
      deleted: true,
      updatedAt: DateTime.now(),
    );
    return await update(updated);
  }

  Future<int> permanentDelete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByDateRange(DateTime start, DateTime end, {bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result;

    if (includeDeleted) {
      result = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE date >= ? AND date <= ?
      ''', [start.toIso8601String(), end.toIso8601String()]);
    } else {
      result = await db.rawQuery('''
        SELECT SUM(amount) as total
        FROM expenses
        WHERE date >= ? AND date <= ? AND deleted = 0
      ''', [start.toIso8601String(), end.toIso8601String()]);
    }

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getTotalByCategory(DateTime start, DateTime end, {bool includeDeleted = false}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;

    if (includeDeleted) {
      maps = await db.rawQuery('''
        SELECT category, SUM(amount) as total
        FROM expenses
        WHERE date >= ? AND date <= ?
        GROUP BY category
      ''', [start.toIso8601String(), end.toIso8601String()]);
    } else {
      maps = await db.rawQuery('''
        SELECT category, SUM(amount) as total
        FROM expenses
        WHERE date >= ? AND date <= ? AND deleted = 0
        GROUP BY category
      ''', [start.toIso8601String(), end.toIso8601String()]);
    }

    final Map<String, double> result = {};
    for (var map in maps) {
      final category = map['category'] as String? ?? 'Uncategorized';
      final total = (map['total'] as num?)?.toDouble() ?? 0.0;
      result[category] = total;
    }
    return result;
  }
}
