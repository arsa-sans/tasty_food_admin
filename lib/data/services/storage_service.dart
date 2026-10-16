import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class StorageService {
  static const String _keyBaseUrl = 'base_url';
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Base URL
  String getBaseUrl() {
    final stored = _prefs.getString(_keyBaseUrl);
    if (stored == null || stored.isEmpty || stored.contains('tastyfood.my.id')) {
      return ApiConstants.defaultBaseUrl;
    }
    return stored;
  }

  Future<bool> setBaseUrl(String url) async {
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    return _prefs.setString(_keyBaseUrl, cleanUrl);
  }

  // Token
  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> setToken(String token) async {
    return _prefs.setString(_keyToken, token);
  }

  Future<bool> removeToken() async {
    return _prefs.remove(_keyToken);
  }

  // User
  UserModel? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<bool> setUser(UserModel user) async {
    return _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<bool> removeUser() async {
    return _prefs.remove(_keyUser);
  }

  // Login Status
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<bool> setLoggedIn(bool value) async {
    return _prefs.setBool(_keyIsLoggedIn, value);
  }

  // Clear Session
  Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
