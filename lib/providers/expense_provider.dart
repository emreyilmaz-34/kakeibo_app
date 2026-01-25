import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/expense_repository.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  final Uuid _uuid = const Uuid();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required double amount,
    required String currency,
    required DateTime date,
    String? category,
    String? note,
    List<String>? tags,
  }) async {
    final now = DateTime.now();
    final expense = Expense(
      id: _uuid.v4(),
      amount: amount,
      currency: currency,
      date: date,
      category: category,
      note: note,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.insert(expense);
      await loadExpenses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    final updated = expense.copyWith(updatedAt: DateTime.now());
    try {
      await _repository.update(updated);
      await loadExpenses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.delete(id);
      await loadExpenses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getByDateRange(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Expense>> searchExpenses(String query) async {
    try {
      return await _repository.search(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<double> getTotalByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getTotalByDateRange(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  Future<Map<String, double>> getTotalByCategory(DateTime start, DateTime end) async {
    try {
      return await _repository.getTotalByCategory(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }
}
