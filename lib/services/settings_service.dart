import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';
import 'dart:convert';

class SettingsService {
  static const String _keySettings = 'settings';
  static const String _keyDeviceId = 'device_id';

  Future<Settings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _getOrCreateDeviceId();

    final settingsJson = prefs.getString(_keySettings);
    if (settingsJson != null) {
      final map = json.decode(settingsJson) as Map<String, dynamic>;
      return Settings.fromMap(map).copyWith(deviceId: deviceId);
    }

    return Settings(deviceId: deviceId);
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final map = settings.toMap();
    await prefs.setString(_keySettings, json.encode(map));
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate a simple device ID (in production, use device_info_plus)
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }

  Future<String> getDeviceId() async {
    return await _getOrCreateDeviceId();
  }
}
