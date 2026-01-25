class Settings {
  final bool isPremium;
  final String preferredCurrency;
  final bool showAds;
  final String deviceId;
  final DateTime? lastSyncAt;

  Settings({
    this.isPremium = false,
    this.preferredCurrency = 'TRY',
    this.showAds = true,
    required this.deviceId,
    this.lastSyncAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium ? 1 : 0,
      'preferredCurrency': preferredCurrency,
      'showAds': showAds ? 1 : 0,
      'deviceId': deviceId,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      isPremium: (map['isPremium'] as int? ?? 0) == 1,
      preferredCurrency: map['preferredCurrency'] as String? ?? 'TRY',
      showAds: (map['showAds'] as int? ?? 1) == 1,
      deviceId: map['deviceId'] as String,
      lastSyncAt: map['lastSyncAt'] != null ? DateTime.parse(map['lastSyncAt'] as String) : null,
    );
  }

  Settings copyWith({
    bool? isPremium,
    String? preferredCurrency,
    bool? showAds,
    String? deviceId,
    DateTime? lastSyncAt,
  }) {
    return Settings(
      isPremium: isPremium ?? this.isPremium,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      showAds: showAds ?? this.showAds,
      deviceId: deviceId ?? this.deviceId,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
