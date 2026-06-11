import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
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

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String phone,
    Uint8List? profileImageBytes,
    String? profileImageName,
  }) async {
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        profileImageBytes: profileImageBytes,
        profileImageName: profileImageName,
      );

      // Tidak langsung set currentUser (supaya redirect ke login)
      if (user != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Register Error: $e");
      rethrow;
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

  /// Update Profile
  Future<bool> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    if (_currentUser == null) return false;
    try {
      await _authService.updateUserProfile(
        uid: _currentUser!.idUser,
        name: name,
        phone: phone,
      );
      // Refresh current user data
      final updatedUser = await _authService.getUserData(_currentUser!.idUser);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print("Update User Profile Error: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}