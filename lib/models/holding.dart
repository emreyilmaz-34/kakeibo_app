class Holding {
  final String id;
  final String symbol;
  final double quantity;
  final String unit;
  final double? buyPrice;
  final DateTime? buyDate;
  final String? note;
  final String? remoteId;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Holding({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.unit,
    this.buyPrice,
    this.buyDate,
    this.note,
    this.remoteId,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'quantity': quantity,
      'unit': unit,
      'buyPrice': buyPrice,
      'buyDate': buyDate?.toIso8601String(),
      'note': note,
      'remoteId': remoteId,
      'deleted': deleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Holding.fromMap(Map<String, dynamic> map) {
    return Holding(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      buyPrice: map['buyPrice'] as double?,
      buyDate: map['buyDate'] != null ? DateTime.parse(map['buyDate'] as String) : null,
      note: map['note'] as String?,
      remoteId: map['remoteId'] as String?,
      deleted: (map['deleted'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Holding copyWith({
    String? id,
    String? symbol,
    double? quantity,
    String? unit,
    double? buyPrice,
    DateTime? buyDate,
    String? note,
    String? remoteId,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Holding(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      buyPrice: buyPrice ?? this.buyPrice,
      buyDate: buyDate ?? this.buyDate,
      note: note ?? this.note,
      remoteId: remoteId ?? this.remoteId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
