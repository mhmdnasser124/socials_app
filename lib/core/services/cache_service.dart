import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

const kUserLoginModelKey = "kUserLoginModelKey";
const kUserTokenKey = "kUserTokenKey";
const kUserRefreshTokenKey = "kUserRefreshTokenKey";
const kFCMTokenKey = "kFCMTokenKey";
const kFirstOpen = "kFirstOpen";
const kSocialsUserIdKey = "kSocialsUserIdKey";

@singleton
class CacheService {
  SharedPreferences? _prefs;
  late final Future<void> _initialization;

  CacheService() {
    _initialization = _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> ensureInitialized() => _initialization;

  SharedPreferences get _preferences {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('CacheService not initialized yet. Call ensureInitialized().');
    }
    return prefs;
  }

  bool isLoggedIn() => _preferences.containsKey(kUserLoginModelKey);

  Future<void> deleteCurrentUserAndToken() async {
    final prefs = _preferences;
    await prefs.remove(kUserLoginModelKey);
    await prefs.remove(kUserTokenKey);
    await prefs.remove(kUserRefreshTokenKey);
  }

  Future<void> updateUserInfo(UserModel user) async {
    await _preferences.setString(kUserLoginModelKey, user.toRawJson());
  }

  Future<void> storeLoggedInUserTokens(
    UserModel user,
    String token,
    String refreshToken,
  ) async {
    final prefs = _preferences;
    await prefs.setString(kUserLoginModelKey, user.toRawJson());
    await prefs.setString(kUserTokenKey, token);
    await prefs.setString(kUserRefreshTokenKey, refreshToken);
  }

  UserModel getLoggedInUser() {
    final result = _preferences.getString(kUserLoginModelKey);
    if (result == null) {
      return UserModel.emptyUser();
    }
    return UserModel.fromRawJson(result);
  }

  Future<void> storeUserToken(String token) async {
    await _preferences.setString(kUserTokenKey, token);
  }

  String? getUserToken() {
    return _preferences.getString(kUserTokenKey);
  }

  Future<void> storeUserRefreshToken(String refreshToken) async {
    await _preferences.setString(kUserRefreshTokenKey, refreshToken);
  }

  String? getUserRefreshToken() {
    return _preferences.getString(kUserRefreshTokenKey);
  }

  Future<void> storeFCMToken(String fCMToken) async {
    await _preferences.setString(kFCMTokenKey, fCMToken);
  }

  String? getFCMToken() {
    return _preferences.getString(kFCMTokenKey);
  }

  Future<void> setFirstOpen() async {
    await _preferences.setBool(kFirstOpen, true);
  }

  bool get checkFirstOpen => _preferences.getBool(kFirstOpen) ?? false;

  Future<void> storeSocialsUserId(String userId) async {
    await _preferences.setString(kSocialsUserIdKey, userId);
  }

  String? getSocialsUserId() {
    return _preferences.getString(kSocialsUserIdKey);
  }
}
