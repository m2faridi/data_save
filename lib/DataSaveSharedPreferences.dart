import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'src/preferences_recovery.dart';

SharedPreferences? prefs;

Future<void> Init({String? windowsPreferencesFilePath}) async {
  prefs = await loadWithCorruptFileReset(
    SharedPreferences.getInstance,
    filePath: Platform.isWindows ? windowsPreferencesFilePath : null,
    detectDefaultWindowsPath: Platform.isWindows,
  );
}

Future<void> SetString(String key, String value) async {
  await prefs!.setString(key, value);
}

Future<void> SetBool(String key, bool value) async {
  await prefs!.setBool(key, value);
}

Future<void> SetInt(String key, int value) async {
  await prefs!.setInt(key, value);
}

Future<void> SetDouble(String key, double value) async {
  await prefs!.setDouble(key, value);
}

Future<void> SetLargeString(String key, String value) => SetString(key, value);

String? GetString(String key) {
  return prefs!.getString(key);
}

bool? GetBool(String key) {
  return prefs!.getBool(key);
}

int? GetInt(String key) {
  return prefs!.getInt(key);
}

double? GetDouble(String key) {
  //
  return prefs!.getDouble(key);
}

String? GetLargeString(String key) => GetString(key);

Future<void> Remove(String key) async {
  if (key.isEmpty) return;
  await prefs!.remove(key);
}

Future<void> RemoveAllLarge() => RemoveAll();

Future<void> RemoveAll() async {
  for (String key in prefs!.getKeys()) {
    await prefs!.remove(key);
  }
}
