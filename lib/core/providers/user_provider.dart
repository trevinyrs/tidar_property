import 'package:flutter/material.dart';
import 'dart:async'; // Tambahkan ini
import '../../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  final AuthService _authService = AuthService();
  StreamSubscription<AppUser?>? _userSubscription;

  /// Mulai mendengarkan perubahan data user secara realtime
  void startUserListener() {
    _userSubscription?.cancel(); // Cancel dulu kalau ada listener lama

    _userSubscription = _authService.userStream.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Load user saat pertama kali aplikasi dibuka
  Future<void> loadUser() async {
    try {
      final user = await _authService.userStream.first;
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      print("Load User Error: $e");
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Tidak langsung set currentUser (supaya redirect ke login)
      if (user != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}