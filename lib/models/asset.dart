enum AssetType {
  stock,
  etf,
  commodity,
  crypto,
  other,
}

class Asset {
  final String symbol;
  final String name;
  final AssetType type;
  final double price;
  final String currency;
  final String unit;
  final DateTime? timestamp;

  Asset({
    required this.symbol,
    required this.name,
    required this.type,
    required this.price,
    required this.currency,
    required this.unit,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type.toString().split('.').last,
      'price': price,
      'currency': currency,
      'unit': unit,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      type: AssetType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AssetType.other,
      ),
      price: (map['price'] as num).toDouble(),
      currency: map['currency'] as String,
      unit: map['unit'] as String,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }

  Asset copyWith({
    String? symbol,
    String? name,
    AssetType? type,
    double? price,
    String? currency,
    String? unit,
    DateTime? timestamp,
  }) {
    return Asset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
