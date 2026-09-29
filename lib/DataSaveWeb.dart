import 'dart:convert';

import 'package:web/web.dart' as web;

const int _defaultLifetimeDays = 90;
const int _maxCookieSize = 4096;
const String _cookiePath = '/';

final Map<String, String> _largeMemoryFallback = <String, String>{};
String? _lastCookieHeader;
Map<String, String> _cachedCookieValues = const <String, String>{};

Future<void> Init({String? windowsPreferencesFilePath}) => Future<void>.value();

Future<void> SetString(String key, String value) {
  _setAndVerify(key, value);
  return Future<void>.value();
}

Future<void> SetStringList(String key, List<String> value) =>
    SetString(key, jsonEncode(value));

Future<void> SetBool(String key, bool value) =>
    SetString(key, value.toString());

Future<void> SetInt(String key, int value) => SetString(key, value.toString());

Future<void> SetDouble(String key, double value) =>
    SetString(key, value.toString());

Future<void> SetLargeString(String key, String value) {
  _validateStorageKey(key);
  _largeMemoryFallback[key] = value;

  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {
    // Some browsers can disable persistent storage. Keep the value available
    // for the lifetime of the current page as a graceful fallback.
  }

  return Future<void>.value();
}

String? GetString(String key) => GetCookie(key);

List<String>? GetStringList(String key) {
  final value = GetCookie(key);
  if (value == null) return null;

  try {
    final decoded = jsonDecode(value);
    if (decoded is List && decoded.every((item) => item is String)) {
      return List<String>.from(decoded);
    }
  } on FormatException {
    // Values written by other setters may not be JSON lists.
  }
  return null;
}

Set<String> GetKeys() {
  final keys = _readCookies().keys.map(_decodeValue).toSet();

  try {
    final storage = web.window.localStorage;
    for (var index = 0; index < storage.length; index++) {
      final key = storage.key(index);
      if (key != null) keys.add(key);
    }
  } catch (_) {
    keys.addAll(_largeMemoryFallback.keys);
  }

  return keys;
}

bool? GetBool(String key) {
  switch (GetCookie(key)?.toLowerCase()) {
    case 'true':
    case '1':
      return true;
    case 'false':
    case '0':
      return false;
    default:
      return null;
  }
}

int? GetInt(String key) {
  final value = GetCookie(key);
  return value == null ? null : int.tryParse(value);
}

double? GetDouble(String key) {
  final value = GetCookie(key);
  return value == null ? null : double.tryParse(value);
}

String? GetLargeString(String key) {
  if (key.isEmpty) return null;

  try {
    final value = web.window.localStorage.getItem(key);
    if (value != null) {
      _largeMemoryFallback[key] = value;
    } else {
      _largeMemoryFallback.remove(key);
    }
    return value;
  } catch (_) {
    // Fall through to the in-memory value.
  }

  return _largeMemoryFallback[key];
}

Future<bool> Remove(String key) async {
  if (key.isEmpty) return false;

  var success = true;
  try {
    _expireCookie(Uri.encodeComponent(key));
    success = GetCookie(key) == null;
  } catch (_) {
    success = false;
  }

  _largeMemoryFallback.remove(key);
  try {
    final storage = web.window.localStorage;
    storage.removeItem(key);
    if (storage.getItem(key) != null) success = false;
  } catch (_) {
    // The cookie and in-memory value have still been removed, but persistent
    // storage could not be checked or cleared.
    success = false;
  }

  return success;
}

Future<void> RemoveAllLarge() {
  _largeMemoryFallback.clear();

  try {
    web.window.localStorage.clear();
  } catch (_) {
    // The in-memory values have still been removed.
  }

  return Future<void>.value();
}

Future<void> RemoveAll() async {
  final cookieNames = _readCookies().keys.toList();

  for (final encodedName in cookieNames) {
    _expireCookie(encodedName);
  }

  await RemoveAllLarge();
}

/// Creates a host-only cookie that is available throughout the application.
///
/// Values and names are URI-encoded so delimiter characters and Unicode are
/// stored safely. Passing zero for [days] removes the cookie.
void CreateCookie(String key, String value, int days) {
  _validateStorageKey(key);
  if (days < 0) {
    throw ArgumentError.value(days, 'days', 'Days cannot be negative.');
  }

  final encodedName = Uri.encodeComponent(key);
  if (days == 0) {
    _expireCookie(encodedName);
    return;
  }

  // Remove cookies created by older versions with an explicit Domain before
  // replacing them with a safer host-only cookie.
  _expireCookie(encodedName);

  final encodedValue = Uri.encodeComponent(value);
  final cookie = _buildCookie(
    encodedName,
    encodedValue,
    maxAgeSeconds: days * Duration.secondsPerDay,
  );

  if (cookie.length > _maxCookieSize) {
    throw ArgumentError.value(
      value,
      'value',
      'The encoded cookie is larger than $_maxCookieSize bytes.',
    );
  }

  web.document.cookie = cookie;
}

String? GetCookie(String key) {
  if (key.isEmpty) return null;
  return _readCookies()[Uri.encodeComponent(key)];
}

void _setAndVerify(String key, String value) {
  CreateCookie(key, value, _defaultLifetimeDays);

  if (GetCookie(key) != value) {
    throw StateError(
      'The browser rejected the cookie. Check its privacy settings and quota.',
    );
  }
}

Map<String, String> _readCookies() {
  // Always read the browser's current cookie header so external writes and
  // expiration remain visible. Reuse parsing and decoding only while it matches.
  final cookies = web.document.cookie;
  if (cookies == _lastCookieHeader) return _cachedCookieValues;

  final values = <String, String>{};
  for (final item in cookies.split(';')) {
    final separator = item.indexOf('=');
    if (separator < 0) continue;

    final name = item.substring(0, separator).trim();
    final value = item.substring(separator + 1).trim();
    // Duplicate names can occur at different paths. Keep the browser's first
    // match, just as the uncached lookup did.
    if (name.isNotEmpty) {
      values.putIfAbsent(name, () => _decodeValue(value));
    }
  }

  _lastCookieHeader = cookies;
  _cachedCookieValues = values;
  return values;
}

String _decodeValue(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    // Cookies written by older versions were not encoded.
    return value;
  } on ArgumentError {
    // Invalid percent escapes can throw ArgumentError instead of FormatException.
    return value;
  }
}

void _expireCookie(String encodedName) {
  final expiredCookie = _buildCookie(
    encodedName,
    '',
    maxAgeSeconds: 0,
    expires: 'Thu, 01 Jan 1970 00:00:00 GMT',
  );

  // Delete the new host-only form.
  web.document.cookie = expiredCookie;

  // Also delete the Domain cookie created by versions <= 0.3.8. Domain is
  // deliberately omitted for new cookies because host-only cookies work on
  // localhost/IP addresses and do not leak to sibling subdomains.
  final hostname = web.window.location.hostname;
  if (_supportsDomainAttribute(hostname)) {
    web.document.cookie = '$expiredCookie; Domain=$hostname';
  }
}

String _buildCookie(
  String encodedName,
  String encodedValue, {
  required int maxAgeSeconds,
  String? expires,
}) {
  final attributes = <String>[
    '$encodedName=$encodedValue',
    'Path=$_cookiePath',
    'Max-Age=$maxAgeSeconds',
    if (expires != null) 'Expires=$expires',
    'SameSite=Lax',
    if (web.window.location.protocol == 'https:') 'Secure',
  ];

  return attributes.join('; ');
}

bool _supportsDomainAttribute(String hostname) {
  if (!hostname.contains('.')) return false;

  // IPv4 and bracket-free IPv6 hosts must use host-only cookies.
  final isIpv4 = hostname
      .split('.')
      .every((part) => int.tryParse(part) != null);
  return !isIpv4 && !hostname.contains(':');
}

void _validateStorageKey(String key) {
  if (key.isEmpty) {
    throw ArgumentError.value(key, 'key', 'Storage keys cannot be empty.');
  }
}
