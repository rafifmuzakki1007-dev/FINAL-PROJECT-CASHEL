import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SessionService {
  static const String _keyUser = 'logged_user';

  // in memory cache
  static UserData? _cachedUser;

  // akses synchronous ke userId — dipakai di KeranjangPage._userId
  static String? get currentUserId => _cachedUser?.idAkun;

  // akses synchronous ke user lengkap
  static UserData? get currentUser => _cachedUser;

  // simpan user setelah login / register / google login
  static Future<void> saveUser(UserData user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // ambil user dari SharedPreferences (async)
  static Future<UserData?> getUser() async {
    if (_cachedUser != null) return _cachedUser;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    _cachedUser = UserData.fromJson(jsonDecode(raw));
    return _cachedUser;
  }

  // restore session saat app dibuka 

  static Future<bool> restoreSession() async {
    final user = await getUser();
    return user != null;
  }

  // cek apakah sudah login 
  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }

  // logout
  static Future<void> logout() async {
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}