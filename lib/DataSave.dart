
import 'DataSaveSharedPreferences.dart'
  if (dart.library.html) 'DataSaveWeb.dart';

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
    await SetDouble(key, value);//
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

  static void removeAll() async {
    RemoveAll();
  }
}

