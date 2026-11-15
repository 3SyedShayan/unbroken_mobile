import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unbroken_mobile/services/fault/faults.dart';

part '_settings_provider.dart';

class SettingsRepo {
  static final SettingsRepo _instance = SettingsRepo._();
  SettingsRepo._();
  factory SettingsRepo() => _instance;
  static SettingsRepo get ins => _instance;

  final _provider = _SettingsProvider();

  Stream<Map<String, dynamic>?> observeSettings(String uid) =>
      _provider.observeSettings(uid);

  Future<void> updateSettings(String uid, Map<String, dynamic> settingsData) =>
      _provider.updateSettings(uid, settingsData);

  Future<void> updateLocalPreferences(Map<String, dynamic> prefs) =>
      _provider.updateLocalPreferences(prefs);

  Future<Map<String, dynamic>> loadLocalPreferences() =>
      _provider.loadLocalPreferences();
}

