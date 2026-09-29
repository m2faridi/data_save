import 'DataSaveSharedPreferences.dart'
    if (dart.library.js_interop) 'DataSaveWeb.dart';

class DataSave {
  /// Loads preferences. On Windows, a [FormatException] during loading deletes
  /// the `shared_preferences.json` file opened by the Windows backend. All its
  /// values are lost. The error is rethrown; restart to load empty preferences.
  /// [windowsPreferencesFilePath] can override the detected path, but is not
  /// needed for the default storage location. Other platforms ignore it.
  static Future<void> init({String? windowsPreferencesFilePath}) async {
    await Init(windowsPreferencesFilePath: windowsPreferencesFilePath);
  }

  static Future<void> setString(String key, String value) async {
    await SetString(key, value);
  }

  /// Stores a string list. On web, the JSON-encoded list uses a cookie and is
  /// subject to the same size limit as [setString].
  static Future<void> setStringList(String key, List<String> value) async {
    await SetStringList(key, value);
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

  /// Reads a value written with [setStringList], or null if the key is missing.
  static List<String>? getStringList(String key) {
    return GetStringList(key);
  }

  /// Returns a snapshot of stored keys. On web, this includes readable cookies
  /// and localStorage keys, or in-memory large-string keys if storage is blocked.
  static Set<String> getKeys() {
    return GetKeys();
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

  /// Returns whether removal succeeded, including when the key was absent.
  /// Empty keys return false. Native backend errors can still throw; on web,
  /// blocked storage or a value that remains after removal returns false.
  static Future<bool> remove(String key) async {
    return await Remove(key);
  }

  static Future<void> removeAllLarge() async {
    await RemoveAllLarge();
  }

  static Future<void> removeAll() async {
    await RemoveAll();
  }
}
