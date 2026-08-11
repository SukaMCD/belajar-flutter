import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_song_ids';
  late SharedPreferences _prefs;

  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;
  bool isFavorite(String songId) => _favoriteIds.contains(songId);

  Future<void> initStorage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedList = _prefs.getStringList(_storageKey) ?? [];
    _favoriteIds.addAll(savedList);
    notifyListeners();
  }

  Future<void> toggleFavorite(String songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }

    notifyListeners();

    await _prefs.setStringList(_storageKey, _favoriteIds.toList());
  }

  Future<void> clearAll() async {
    _favoriteIds.clear();
    notifyListeners();
    await _prefs.remove(_storageKey);
  }
}

