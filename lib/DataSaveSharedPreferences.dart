import 'package:shared_preferences/shared_preferences.dart';

const String _largeStoragePrefix = 'data_save.large.';

SharedPreferences? prefs;

Future<void> Init() async {
  prefs = await SharedPreferences.getInstance();
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

Future<void> SetLargeString(String key, String value) async {
  _validateStorageKey(key);
  await prefs!.setString(_largeStorageKey(key), value);
}

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

String? GetLargeString(String key) {
  if (key.isEmpty) return null;
  return prefs!.getString(_largeStorageKey(key));
}

Future<void> Remove(String key) async {
  if (key.isEmpty) return;
  await prefs!.remove(key);
}

Future<void> RemoveLarge(String key) async {
  if (key.isEmpty) return;
  await prefs!.remove(_largeStorageKey(key));
}

Future<void> RemoveAllLarge() async {
  final keys = prefs!
      .getKeys()
      .where((key) => key.startsWith(_largeStoragePrefix))
      .toList();
  for (final key in keys) {
    await prefs!.remove(key);
  }
}

Future<void> RemoveAll() async {
  for (String key in prefs!.getKeys()) {
    await prefs!.remove(key);
  }
}

String _largeStorageKey(String key) =>
    '$_largeStoragePrefix${Uri.encodeComponent(key)}';

void _validateStorageKey(String key) {
  if (key.isEmpty) {
    throw ArgumentError.value(key, 'key', 'Storage keys cannot be empty.');
  }
}
