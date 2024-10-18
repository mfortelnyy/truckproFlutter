import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  //session info
  static const String _tokenKey = 'authToken';
  static const String _userIdKey = 'userId';

  //save data
  Future<void> saveSession(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
  }

  // get session token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // get user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // for logging out
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  static DateTime? getExpiryDate(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null; // Invalid JWT format
    }

    // decode the payload 
    final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

    if (payload['exp'] != null) {
      final exp = payload['exp'];
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000); // seconds to milliseconds
    }

    return null;
  }


  static bool isTokenExpired(String token) {
    final expiryDate = getExpiryDate(token);
    if (expiryDate == null) {
      return true; // expired if can't decode
    }
    return DateTime.now().isAfter(expiryDate);
  }
}
