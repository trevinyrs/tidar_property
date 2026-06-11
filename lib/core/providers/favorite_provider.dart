import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> _favoriteIds = [];
  List<String> get favoriteIds => _favoriteIds;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList('favorite_properties') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal memuat favorit: $e");
    }
  }

  bool isFavorite(String propertyId) {
    return _favoriteIds.contains(propertyId);
  }

  Future<void> toggleFavorite(String propertyId) async {
    if (_favoriteIds.contains(propertyId)) {
      _favoriteIds.remove(propertyId);
    } else {
      _favoriteIds.add(propertyId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_properties', _favoriteIds);
    } catch (e) {
      debugPrint("Gagal menyimpan favorit: $e");
    }
  }
}
