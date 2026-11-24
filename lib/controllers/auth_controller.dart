import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  static const String _userPrefKey = 'redepatas_current_user';
  static const String _onboardingPrefKey = 'redepatas_onboarding_done';
  static const String _newRequestTipKey = 'redepatas_tip_new_request_dismissed';

  UserModel? _currentUser;
  bool _isInitialized = false;
  bool _onboardingDone = false;
  bool _newRequestTipDismissed = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get onboardingDone => _onboardingDone;
  bool get newRequestTipDismissed => _newRequestTipDismissed;
  bool get isOrganization => _currentUser?.role == UserRole.organization;
  bool get isVolunteer => _currentUser?.role == UserRole.volunteer;

  AuthController() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool(_onboardingPrefKey) ?? false;
    _newRequestTipDismissed = prefs.getBool(_newRequestTipKey) ?? false;

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

  Future<void> completeOnboarding() async {
    if (_onboardingDone) return;
    _onboardingDone = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingPrefKey, true);
  }

  Future<void> resetOnboarding() async {
    _onboardingDone = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingPrefKey, false);
  }

  Future<void> dismissNewRequestTip() async {
    if (_newRequestTipDismissed) return;
    _newRequestTipDismissed = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newRequestTipKey, true);
  }

  Future<void> signIn({
    required String name,
    required String email,
    String? phone,
    String defaultCity = 'Rio do Sul',
    UserRole role = UserRole.citizen,
    String? organizationId,
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
      role: role,
      organizationId: organizationId ??
          (role == UserRole.organization ? 'org_apad_demo' : null),
    );

    _currentUser = user;
    _onboardingDone = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingPrefKey, true);
    await prefs.setString(_userPrefKey, json.encode(user.toJson()));
  }

  Future<void> signInAsDemo({UserRole role = UserRole.volunteer}) async {
    final demoUser = UserModel(
      id: role == UserRole.organization ? 'user_ong_demo' : 'user_demo',
      name: role == UserRole.organization
          ? 'APAD Rio do Sul (ONG Demo)'
          : 'Lucas & Ariel (Demo)',
      email: role == UserRole.organization
          ? 'contato@apad.org.br'
          : 'contato@redepatas.org.br',
      phone: '47999556677',
      defaultCity: 'Rio do Sul',
      role: role,
      organizationId: role == UserRole.organization ? 'org_apad_demo' : null,
    );
    _currentUser = demoUser;
    _onboardingDone = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingPrefKey, true);
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

  Future<void> updateRole(UserRole role, {String? organizationId}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      role: role,
      organizationId: organizationId ??
          (role == UserRole.organization
              ? (_currentUser!.organizationId ?? 'org_apad_demo')
              : _currentUser!.organizationId),
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
