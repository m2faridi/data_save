## 0.4.0

- Migrated the web implementation from deprecated `dart:html` APIs to
  `package:web`.
- Added JavaScript and WebAssembly-compatible platform selection.
- Safely encode cookie names and values, including Unicode and delimiters.
- Use host-only cookies with `SameSite=Lax` and `Secure` on HTTPS.
- Detect rejected and oversized cookies instead of failing silently.
- Return `null` for missing or invalid typed values consistently.
- Made `DataSave.removeAll()` awaitable.
- Increased the minimum supported Dart SDK to 3.13.

## 0.3.6

- Improved Flutter and Flutter Web compatibility.

## 0.0.1

- Initial release.
