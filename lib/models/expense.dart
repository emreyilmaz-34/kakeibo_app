class Expense {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String? category;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;
  final bool deleted;

  Expense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    this.category,
    this.note,
    List<String>? tags,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.deleted = false,
  }) : tags = tags ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'category': category,
      'note': note,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'remoteId': remoteId,
      'deleted': deleted ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String?,
      note: map['note'] as String?,
      tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      remoteId: map['remoteId'] as String?,
      deleted: (map['deleted'] as int? ?? 0) == 1,
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remoteId,
    bool? deleted,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      deleted: deleted ?? this.deleted,
    );
  }
}
