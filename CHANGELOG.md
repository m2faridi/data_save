## 0.4.5

- Added `DataSave.getKeys()` to list stored keys on native platforms and web.
- Added `setStringList()` and `getStringList()` with JSON cookie storage on web.
- Changed `remove()` to return `Future<bool>` indicating removal success.

## 0.4.4

- Detect the default Windows preferences file during loading, so corrupt-file
  recovery works with `DataSave.init()` without supplying a path or adding any
  dependency. An explicit `windowsPreferencesFilePath` remains supported.

## 0.4.3

- Added an optional `windowsPreferencesFilePath` to `DataSave.init()`. If loading
  on Windows throws `FormatException`, the supplied file is deleted so the next
  launch can start empty. Storage still uses SharedPreferences with no new
  dependencies; other load errors do not delete data.

## 0.4.0

- Migrated the web implementation from deprecated `dart:html` APIs to
  `package:web`.
- Added JavaScript and WebAssembly-compatible platform selection.
- Safely encode cookie names and values, including Unicode and delimiters.
- Use host-only cookies with `SameSite=Lax` and `Secure` on HTTPS.
- Detect rejected and oversized cookies instead of failing silently.
- Return `null` for missing or invalid typed values consistently.
- Made `DataSave.removeAll()` awaitable.
- Added `setLargeString()` and `getLargeString()` using `localStorage` on web
  with an in-memory fallback.
- Added `remove()` for clearing the same key from both web storage modes and
  `removeAllLarge()` for clearing large-string storage.
- `removeAll()` now clears both cookies and all `localStorage` values on web;
  large-string methods reuse the normal storage on native platforms.
- Increased the minimum supported Dart SDK to 3.13.

## 0.3.6

- Improved Flutter and Flutter Web compatibility.

## 0.0.1

- Initial release.
