import 'package:web/web.dart' as web;

const int _defaultLifetimeDays = 90;
const int _maxCookieSize = 4096;
const String _cookiePath = '/';

final Map<String, String> _largeMemoryFallback = <String, String>{};

Future<void> Init() => Future<void>.value();

Future<void> SetString(String key, String value) {
  _setAndVerify(key, value);
  return Future<void>.value();
}

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

Future<void> Remove(String key) {
  if (key.isEmpty) return Future<void>.value();
  _expireCookie(Uri.encodeComponent(key));
  return Future<void>.value();
}

Future<void> RemoveLarge(String key) {
  if (key.isEmpty) return Future<void>.value();

  _largeMemoryFallback.remove(key);
  try {
    web.window.localStorage.removeItem(key);
  } catch (_) {
    // The in-memory value has still been removed.
  }

  return Future<void>.value();
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
  final cookieNames = _cookieEntries().map((entry) => entry.$1).toSet();

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

  final encodedName = Uri.encodeComponent(key);
  for (final entry in _cookieEntries()) {
    if (entry.$1 == encodedName) {
      return _decodeValue(entry.$2);
    }
  }

  return null;
}

void _setAndVerify(String key, String value) {
  CreateCookie(key, value, _defaultLifetimeDays);

  if (GetCookie(key) != value) {
    throw StateError(
      'The browser rejected the cookie. Check its privacy settings and quota.',
    );
  }
}

Iterable<(String, String)> _cookieEntries() sync* {
  final cookies = web.document.cookie;
  if (cookies.isEmpty) return;

  for (final item in cookies.split(';')) {
    final separator = item.indexOf('=');
    if (separator < 0) continue;

    final name = item.substring(0, separator).trim();
    final value = item.substring(separator + 1).trim();
    if (name.isNotEmpty) yield (name, value);
  }
}

String _decodeValue(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    // Cookies written by older versions were not encoded.
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
