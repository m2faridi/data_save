import 'DataSaveSharedPreferences.dart'
    if (dart.library.js_interop) 'DataSaveWeb.dart';

class DataSave {
  static Future<void> init() async {
    await Init();
  }

  static Future<void> setString(String key, String value) async {
    await SetString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await SetBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await SetInt(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await SetDouble(key, value); //
  }

  /// Stores a larger string in localStorage on web and SharedPreferences on
  /// native platforms.
  static Future<void> setLargeString(String key, String value) async {
    await SetLargeString(key, value);
  }

  static String? getString(String key) {
    return GetString(key);
  }

  static bool? getBool(String key) {
    return GetBool(key);
  }

  static int? getInt(String key) {
    return GetInt(key);
  }

  static double? getDouble(String key) {
    return GetDouble(key);
  }

  /// Reads a value written with [setLargeString].
  static String? getLargeString(String key) {
    return GetLargeString(key);
  }

  static Future<void> remove(String key) async {
    await Remove(key);
  }

  static Future<void> removeLarge(String key) async {
    await RemoveLarge(key);
  }

  static Future<void> removeAllLarge() async {
    await RemoveAllLarge();
  }

  static Future<void> removeAll() async {
    await RemoveAll();
  }
}
