import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';

class StorageService {
  static const String _keyToken = '@taskflow_access_token';
  static const String _keyRefreshToken = '@taskflow_refresh_token';
  static const String _keyUser = '@taskflow_user_profile';
  static const String _keySessionActive = '@taskflow_session_active';
  static const String _keyRememberMe = '@taskflow_remember_me';
  static const String _keyRememberedEmail = '@taskflow_remembered_email';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // Initialize service instance
  static Future<StorageService> init() async {
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    final prefs = await SharedPreferences.getInstance();
    return StorageService(secureStorage: secure, prefs: prefs);
  }

  // Token Management (Access Token & Refresh Token)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _prefs.setString(_keySessionActive, 'true');
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
    await _prefs.remove(_keySessionActive);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _keyRefreshToken);
  }

  // User Profile Caching
  Future<void> saveUser(UserProfile user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _prefs.setString(_keyUser, jsonStr);
  }

  UserProfile? getUser() {
    final jsonStr = _prefs.getString(_keyUser);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_keyUser);
  }

  // Clear entire authenticated session
  Future<void> clearSession() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUser();
  }

  // Remember Me support
  Future<void> setRememberMe(bool remember, {String? email}) async {
    await _prefs.setBool(_keyRememberMe, remember);
    if (remember && email != null) {
      await _prefs.setString(_keyRememberedEmail, email);
    } else {
      await _prefs.remove(_keyRememberedEmail);
    }
  }

  bool getRememberMe() => _prefs.getBool(_keyRememberMe) ?? false;
  String? getRememberedEmail() => _prefs.getString(_keyRememberedEmail);

  // Generic Preferences Access
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);
}
