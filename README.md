# data_save

One API for storing small values in Flutter applications. `data_save` uses
`SharedPreferences` on native platforms and persistent cookies on Flutter Web.

## Features

- Supports `String`, `bool`, `int`, and `double` values.
- Uses URI encoding for safe Unicode and delimiter storage on the web.
- Uses host-only cookies with `SameSite=Lax` and `Secure` on HTTPS.
- Supports Flutter Web builds compiled to JavaScript or WebAssembly.

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
await DataSave.setBool('darkMode', true);
await DataSave.setInt('launchCount', 4);
await DataSave.setDouble('volume', 0.75);

final name = DataSave.getString('name');
final darkMode = DataSave.getBool('darkMode');
final launchCount = DataSave.getInt('launchCount');
final volume = DataSave.getDouble('volume');
```

Remove stored values:

```dart
await DataSave.removeAll();
```

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
