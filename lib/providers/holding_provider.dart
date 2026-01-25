import 'package:flutter/foundation.dart';
import '../models/holding.dart';
import '../services/holding_repository.dart';
import 'package:uuid/uuid.dart';

class HoldingProvider with ChangeNotifier {
  final HoldingRepository _repository = HoldingRepository();
  final Uuid _uuid = const Uuid();

  List<Holding> _holdings = [];
  bool _isLoading = false;
  String? _error;

  List<Holding> get holdings => _holdings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHoldings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _holdings = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHolding({
    required String symbol,
    required double quantity,
    required String unit,
    double? buyPrice,
    DateTime? buyDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final holding = Holding(
      id: _uuid.v4(),
      symbol: symbol,
      quantity: quantity,
      unit: unit,
      buyPrice: buyPrice,
      buyDate: buyDate,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.insert(holding);
      await loadHoldings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHolding(Holding holding) async {
    final updated = holding.copyWith(updatedAt: DateTime.now());
    try {
      await _repository.update(updated);
      await loadHoldings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHolding(String id) async {
    try {
      await _repository.delete(id);
      await loadHoldings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
