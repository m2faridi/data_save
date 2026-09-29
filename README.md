# data_save

A simple static API for storing preferences in Flutter applications. `data_save`
builds on `SharedPreferences` on native platforms and adds persistent cookies,
localStorage for larger strings on web, and automatic reset of corrupt Windows
preferences files.

## Why choose data_save over using shared_preferences directly?

`data_save` is a convenient choice when your app needs a shared storage helper,
cookie-based web preferences, or recovery from a corrupt Windows preferences
file. It bundles these behaviors so you can use them without writing your own
platform-specific wrapper:

- **Less setup at each call site.** Initialize once with `await DataSave.init()`,
  then call `DataSave.getString(...)` or `DataSave.setString(...)` directly.
  There is no preferences instance to pass between screens and services.
- **Built-in web cookies.** Normal values use cookies with a 90-day lifetime,
  URI encoding, `SameSite=Lax`, and `Secure` on HTTPS. Writes check for oversized
  or rejected cookies. This is useful when your app specifically needs
  cookie-backed preferences; `shared_preferences` uses localStorage on web.
  See its [storage documentation](https://pub.dev/packages/shared_preferences#storage-location-by-platform).
- **Two web storage modes through one API.** Use `setLargeString()` and
  `getLargeString()` for values that exceed cookie limits. These use localStorage,
  with a page-lifetime memory fallback while localStorage is inaccessible.
  `getKeys()` combines both stores, and `remove(key)` clears the key from both.
- **Automatic Windows reset after a decoding failure.** If initialization throws
  `FormatException`, the detected preferences file is deleted so the next app
  launch can start with empty preferences. The current initialization still
  throws, and all values in that file are lost. See
  [Windows recovery](#reset-a-corrupt-windows-preferences-file) for details.

On native platforms, `data_save` uses the legacy `SharedPreferences` API and
inherits its storage and cache behavior. String lists, key enumeration, and
boolean removal results are also available in that API. The added value is the
convenient interface and the web and Windows behaviors above. For apps that need
fresh native values across isolates or background engines, consider
[`SharedPreferencesAsync`](https://pub.dev/packages/shared_preferences#cache-and-async-or-sync-getters).

## Features

- Supports `String`, `List<String>`, `bool`, `int`, and `double` values.
- Lists stored keys and reports whether removing a key succeeded.
- Uses URI encoding for safe Unicode and delimiter storage on the web.
- Uses host-only cookies with `SameSite=Lax` and `Secure` on HTTPS.
- Supports Flutter Web builds compiled to JavaScript or WebAssembly.

## Performance

Native `removeAll()` and `removeAllLarge()` use a single SharedPreferences clear
operation, avoiding a separate backend call for every key. The configured
SharedPreferences prefix and allowList still apply.

On web, repeated reads reuse parsed and decoded cookies while the browser's
cookie header is unchanged. Each read still checks the current header, so external
cookie changes and expiration are visible immediately. The browser access itself
remains synchronous.

To measure repeated reads with 1, 25, and 100 cookies on your machine, run:

```sh
flutter test --platform chrome test/benchmark/web_read_benchmark.dart
```

This benchmark reports the median of seven samples in a development build.
Results depend on the browser, device, cookie count, and workload.

## Installation

```yaml
dependencies:
  data_save: ^0.4.0
```

## Usage

Initialize the library before reading or writing values:

```dart
import 'package:data_save/DataSave.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataSave.init();
  runApp(const MyApp());
}
```

Store and retrieve values:

```dart
await DataSave.setString('name', 'Sara');
await DataSave.setStringList('favorites', ['Dart', 'Flutter']);
await DataSave.setBool('darkMode', true);
await DataSave.setInt('launchCount', 4);
await DataSave.setDouble('volume', 0.75);

final name = DataSave.getString('name');
final favorites = DataSave.getStringList('favorites');
final darkMode = DataSave.getBool('darkMode');
final launchCount = DataSave.getInt('launchCount');
final volume = DataSave.getDouble('volume');
final Set<String> keys = DataSave.getKeys();
```

`getStringList()` returns `null` for a missing key and preserves empty lists.
On web, lists are stored as JSON in cookies and share the cookie size limit.
`getKeys()` returns a snapshot of all SharedPreferences keys on native platforms.
On web, it combines readable cookie names and the origin's `localStorage` keys,
without duplicates, and includes in-memory large-string keys if storage is blocked.

Remove stored values:

```dart
final bool removed = await DataSave.remove('name');
await DataSave.removeAll();
```

`remove()` reports whether removal succeeded, including when the key was already
absent. An empty key returns `false`. On web, removal clears both storage modes
and returns `false` if storage is blocked or a value remains. On native platforms,
it returns the SharedPreferences result; backend exceptions still propagate.

### Reset a corrupt Windows preferences file

Windows automatically detects the `shared_preferences.json` file opened by
SharedPreferences. No path or additional dependency is needed:

```dart
await DataSave.init();
```

On Windows, if loading throws `FormatException`, the detected file is deleted and the
error is rethrown. Close and reopen the app: preferences will be empty and the
first successful save recreates the file. **All values in the deleted file are
lost.**

Other errors (including access and disk errors) do not trigger deletion.
Other platforms retain their previous behavior. The optional
`windowsPreferencesFilePath` argument is still available to override detection;
if used, supply only the full path of this application's preferences file.
If the backend does not expose a unique preferences file, automatic deletion is
skipped and the load error is rethrown.
This recovers from an unreadable preferences document; it does not prevent
power-loss corruption or detect damaged JSON stored inside a string value.

### Larger strings

Use the large-string API for JSON and other values that can exceed the cookie
limit. It uses `localStorage` on web and the same `SharedPreferences` storage
as the normal API on native platforms:

```dart
await DataSave.setLargeString('economicCalendar', jsonString);

final jsonString = DataSave.getLargeString('economicCalendar');

await DataSave.remove('economicCalendar');
await DataSave.removeAllLarge();
```

On web, `removeAll()` clears both cookies and the origin's entire
`localStorage`. On native platforms, normal and large-string methods use the
same `SharedPreferences` storage.

## Web behavior

Web values are stored as first-party cookies for 90 days. Browser cookie limits
apply, so this package is intended for small values rather than documents or
large JSON payloads.

Cookies created in browser code cannot use the `HttpOnly` attribute. Do not use
this package to store passwords, private keys, or long-lived authentication
secrets.
