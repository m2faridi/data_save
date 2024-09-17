

import 'package:shared_preferences/shared_preferences.dart';



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

String? GetString(String key) {
  return prefs!.getString(key);
}

bool? GetBool(String key) {
  return prefs!.getBool(key);
}

int? GetInt(String key) {
  return prefs!.getInt(key);
}

double? GetDouble(String key) {//
  return prefs!.getDouble(key);
}

void RemoveAll() async {
  // prefs!.getKeys();
  // for (String key in prefs!.getKeys()) {
  //   await prefs!.remove(key);
  // }
}


