import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService extends Notifier<String?> {
  static const _keyPref = 'gemini_api_key';

  @override
  String? build() {
    _loadKey();
    return null;
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_keyPref);
  }

  Future<void> setKey(String key) async {
    if (key.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPref, key.trim());
    state = key.trim();
  }

  Future<void> deleteKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPref);
    state = null;
  }
}

final apiKeyProvider = NotifierProvider<ApiKeyService, String?>(() {
  return ApiKeyService();
});
