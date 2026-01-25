import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _service = SettingsService();
  Settings? _settings;
  bool _isLoading = false;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isPremium => _settings?.isPremium ?? false;
  String get preferredCurrency => _settings?.preferredCurrency ?? 'TRY';
  bool get showAds => _settings?.showAds ?? true;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _service.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(Settings newSettings) async {
    try {
      await _service.saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
      rethrow;
    }
  }

  Future<void> setPremium(bool isPremium) async {
    if (_settings == null) {
      await loadSettings();
    }
    final updated = _settings!.copyWith(isPremium: isPremium, showAds: !isPremium);
    await updateSettings(updated);
  }

  Future<void> setPreferredCurrency(String currency) async {
    if (_settings == null) {
      await loadSettings();
    }
    final updated = _settings!.copyWith(preferredCurrency: currency);
    await updateSettings(updated);
  }
}
