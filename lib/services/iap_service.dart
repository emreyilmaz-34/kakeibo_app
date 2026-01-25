// Temporarily disabled for mock data testing
// TODO: Uncomment when in_app_purchase package is added back

// import 'dart:async';
// import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final IAPService instance = IAPService._internal();

  IAPService._internal();

  bool get isAvailable => false;
  // List<ProductDetails> get products => [];
  List<dynamic> get products => [];

  Future<void> initialize() async {
    // Stub - no-op for mock data testing
  }

  Future<void> loadProducts() async {
    // Stub - no-op for mock data testing
  }

  Future<bool> purchaseProduct(dynamic product) async {
    // Stub - no-op for mock data testing
    return false;
  }

  Future<void> restorePurchases() async {
    // Stub - no-op for mock data testing
  }

  void dispose() {
    // Stub - no-op for mock data testing
  }
}
