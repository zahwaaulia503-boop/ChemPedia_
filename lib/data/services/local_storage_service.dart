import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/extra_models.dart';

class LocalStorageService {
  static const String _keyProfile = 'user_profile';
  static const String _keyFavorites = 'favorite_materials';
  static const String _keyCoins = 'chem_coins';
  static const String _keyLastDailyClaim = 'last_daily_claim';
  static const String _keyQuizHistory = 'quiz_history';
  static const String _keyUnlockedMysteries = 'unlocked_mysteries';

  // Cache keys
  static const String _keyCacheMaterials = 'cache_materials';
  static const String _keyCacheElements = 'cache_elements';
  static const String _keyCacheGlossary = 'cache_glossary';
  static const String _keyCacheDailyFacts = 'cache_daily_facts';
  static const String _keyCacheMysteries = 'cache_mysteries';

  static LocalStorageService? _instance;
  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = LocalStorageService._(prefs);
    }
    return _instance!;
  }

  // --- 1. USER PROFILE ---
  bool hasProfile() {
    return _prefs.containsKey(_keyProfile);
  }

  UserProfileModel? getProfile() {
    final str = _prefs.getString(_keyProfile);
    if (str == null) return null;
    try {
      return UserProfileModel.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveProfile(UserProfileModel profile) {
    return _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // --- 2. FAVORITES (BOOKMARKS) ---
  List<String> getFavorites() {
    return _prefs.getStringList(_keyFavorites) ?? [];
  }

  bool isFavorite(String materialId) {
    final list = getFavorites();
    return list.contains(materialId);
  }

  Future<bool> toggleFavorite(String materialId) async {
    final list = getFavorites().toList();
    if (list.contains(materialId)) {
      list.remove(materialId);
    } else {
      list.add(materialId);
    }
    return _prefs.setStringList(_keyFavorites, list);
  }

  // --- 3. CHEMCOINS & GAMIFIKASI ---
  int getCoins() {
    // Default 25 koin awal sebagai bonus selamat datang siswa baru
    return _prefs.getInt(_keyCoins) ?? 25;
  }

  Future<bool> addCoins(int amount) {
    final current = getCoins();
    return _prefs.setInt(_keyCoins, current + amount);
  }

  Future<bool> spendCoins(int amount) {
    final current = getCoins();
    if (current < amount) return Future.value(false);
    return _prefs.setInt(_keyCoins, current - amount);
  }

  bool canClaimDailyCoin() {
    final lastStr = _prefs.getString(_keyLastDailyClaim);
    if (lastStr == null) return true;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    return lastStr != todayStr;
  }

  Future<bool> claimDailyCoin(int rewardAmount) async {
    if (!canClaimDailyCoin()) return false;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    await _prefs.setString(_keyLastDailyClaim, todayStr);
    return addCoins(rewardAmount);
  }

  // --- 4. RIWAYAT KUIS ---
  List<Map<String, dynamic>> getQuizHistory() {
    final strList = _prefs.getStringList(_keyQuizHistory) ?? [];
    return strList.map((s) {
      try {
        return jsonDecode(s) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<void> saveQuizResult({
    required String quizTitle,
    required int score,
    required int correctCount,
    required int totalQuestions,
  }) async {
    final list = _prefs.getStringList(_keyQuizHistory) ?? [];
    final entry = {
      'quiz_title': quizTitle,
      'score': score,
      'correct_count': correctCount,
      'total_questions': totalQuestions,
      'date': DateTime.now().toIso8601String(),
    };
    list.insert(0, jsonEncode(entry));
    // Batasi 30 riwayat terakhir
    if (list.length > 30) list.removeLast();
    await _prefs.setStringList(_keyQuizHistory, list);
  }

  // --- 5. MISTERI KIMIA TERKUNCI ---
  List<String> getUnlockedMysteries() {
    return _prefs.getStringList(_keyUnlockedMysteries) ?? [];
  }

  bool isMysteryUnlocked(String mysteryId) {
    return getUnlockedMysteries().contains(mysteryId);
  }

  Future<bool> unlockMystery(String mysteryId) async {
    final list = getUnlockedMysteries().toList();
    if (!list.contains(mysteryId)) {
      list.add(mysteryId);
      return _prefs.setStringList(_keyUnlockedMysteries, list);
    }
    return true;
  }

  // --- 6. CACHE OFFLINE PERSISTENCE ---
  Future<void> cacheData(String cacheKey, dynamic data) async {
    await _prefs.setString(cacheKey, jsonEncode(data));
  }

  dynamic getCachedData(String cacheKey) {
    final str = _prefs.getString(cacheKey);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  String get keyMaterials => _keyCacheMaterials;
  String get keyElements => _keyCacheElements;
  String get keyGlossary => _keyCacheGlossary;
  String get keyDailyFacts => _keyCacheDailyFacts;
  String get keyMysteries => _keyCacheMysteries;
}
