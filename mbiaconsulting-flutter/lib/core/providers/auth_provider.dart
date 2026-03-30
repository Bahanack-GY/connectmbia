import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SocketService _socketService;

  UserModel? _user;
  String? _token;
  bool _initializing = true; // true while restoring session on startup

  AuthProvider(this._socketService);

  UserModel? get user => _user;
  String? get token => _token;
  bool get isInitializing => _initializing;
  bool get isAuthenticated => _token != null && _user != null;

  ApiService get _api => ApiService(token: _token);

  // ── Called once on app startup ─────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');

    if (_token != null && userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _socketService.connect(_token!);
        // Silently refresh profile in background
        _refreshUser();
      } catch (_) {
        await _clearSession();
      }
    }

    _initializing = false;
    notifyListeners();
  }

  // ── Auth actions ───────────────────────────────────────────────────────────

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final data = await ApiService().post('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    }) as Map<String, dynamic>;

    await _handleAuthResponse(data);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final data = await ApiService().post('/auth/signin', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    await _handleAuthResponse(data);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final updated =
        await _api.patch('/users/me', data) as Map<String, dynamic>;
    _user = UserModel.fromJson(updated);
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    _socketService.disconnect();
    await _clearSession();
    notifyListeners();
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    _token = data['accessToken']?.toString();
    _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _persist();
    if (_token != null) _socketService.connect(_token!);
    notifyListeners();
  }

  Future<void> _refreshUser() async {
    try {
      final data = await _api.get('/users/me') as Map<String, dynamic>;
      _user = UserModel.fromJson(data);
      await _persist();
      notifyListeners();
    } catch (_) {
      // Keep cached user on transient errors
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('auth_token', _token!);
    if (_user != null) {
      await prefs.setString('auth_user', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> _clearSession() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }
}
