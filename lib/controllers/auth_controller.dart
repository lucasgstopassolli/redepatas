import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  static const String _userPrefKey = 'redepatas_current_user';

  UserModel? _currentUser;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthController() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userPrefKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(decoded);
      } catch (_) {
        _currentUser = null;
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signIn({
    required String name,
    required String email,
    String? phone,
    String defaultCity = 'Rio do Sul',
  }) async {
    final cleanName = name.trim().isEmpty ? 'Voluntário RedePatas' : name.trim();
    final cleanEmail =
        email.trim().isEmpty ? 'voluntario@redepatas.org' : email.trim();

    final user = UserModel(
      id: 'user_${cleanEmail.toLowerCase().hashCode.abs()}',
      name: cleanName,
      email: cleanEmail,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      defaultCity: defaultCity,
    );

    _currentUser = user;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefKey, json.encode(user.toJson()));
  }

  Future<void> signInAsDemo() async {
    const demoUser = UserModel(
      id: 'user_demo',
      name: 'Lucas & Ariel (Demo)',
      email: 'contato@redepatas.org.br',
      phone: '47999556677',
      defaultCity: 'Rio do Sul',
    );
    _currentUser = demoUser;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefKey, json.encode(demoUser.toJson()));
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    required String defaultCity,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      defaultCity: defaultCity,
    );
    _currentUser = updated;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefKey, json.encode(updated.toJson()));
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPrefKey);
  }
}
