@TestOn('browser')
library;

import 'package:data_save/DataSave.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  setUp(() async {
    await DataSave.init();
    await DataSave.removeAll();
  });

  tearDown(DataSave.removeAll);

  test(
    'round-trips string lists with Unicode, delimiters and empty strings',
    () async {
      final values = <String>[
        'Dart',
        'فارسی; value=100% ✓',
        '',
        'Dart',
        '"\\[]',
      ];

      await DataSave.setStringList('favorites', values);

      expect(DataSave.getStringList('favorites'), values);
      values.add('unsaved');
      DataSave.getStringList('favorites')!.clear();
      expect(DataSave.getStringList('favorites'), [
        'Dart',
        'فارسی; value=100% ✓',
        '',
        'Dart',
        '"\\[]',
      ]);
    },
  );

  test(
    'distinguishes missing and empty string lists and replaces lists',
    () async {
      expect(DataSave.getStringList('favorites'), isNull);

      await DataSave.setStringList('favorites', ['old']);
      await DataSave.setStringList('favorites', []);

      expect(DataSave.getStringList('favorites'), isEmpty);
    },
  );

  test(
    'returns null for invalid JSON or a value that is not a string list',
    () async {
      for (final value in [
        'not json',
        'null',
        '42',
        '{}',
        '"text"',
        '["a", 1]',
      ]) {
        await DataSave.setString('invalid-list', value);

        expect(DataSave.getStringList('invalid-list'), isNull, reason: value);
      }
    },
  );

  test(
    'getKeys combines decoded cookies and localStorage without duplicates',
    () async {
      expect(DataSave.getKeys(), isEmpty);
      await DataSave.setString('کلید; =100%', 'text');
      await DataSave.setStringList('list', ['one']);
      await DataSave.setBool('bool', true);
      await DataSave.setInt('int', 42);
      await DataSave.setDouble('double', 3.14);
      await DataSave.setLargeString('large', 'text');
      await DataSave.setLargeString('list', 'same key in both stores');
      web.window.localStorage.setItem('external%20key', 'value');

      final keys = DataSave.getKeys();
      expect(keys, {
        'کلید; =100%',
        'list',
        'bool',
        'int',
        'double',
        'large',
        'external%20key',
      });

      expect(await DataSave.remove('list'), isTrue);
      expect(DataSave.getStringList('list'), isNull);
      expect(DataSave.getLargeString('list'), isNull);
      expect(keys, contains('list'));
      expect(DataSave.getKeys(), isNot(contains('list')));
      keys.clear();
      expect(DataSave.getKeys(), isNotEmpty);

      await DataSave.removeAll();
      expect(DataSave.getKeys(), isEmpty);
    },
  );

  test(
    'getKeys does not include stale memory when localStorage is available',
    () async {
      await DataSave.setLargeString('removed-externally', 'value');
      web.window.localStorage.removeItem('removed-externally');

      expect(DataSave.getKeys(), isNot(contains('removed-externally')));
    },
  );

  test('remove succeeds for an absent key and rejects an empty key', () async {
    await DataSave.setString('keep', 'value');

    expect(await DataSave.remove('missing'), isTrue);
    expect(await DataSave.remove(''), isFalse);
    expect(DataSave.getString('keep'), 'value');
  });

  test('round-trips cookie delimiters and Unicode', () async {
    const value = 'متن فارسی; value=100% ✓';

    await DataSave.setString('complex key', value);

    expect(DataSave.getString('complex key'), value);
  });

  test('preserves an empty string', () async {
    await DataSave.setString('empty', '');

    expect(DataSave.getString('empty'), '');
  });

  test('round-trips supported value types', () async {
    await DataSave.setBool('bool', true);
    await DataSave.setInt('int', 42);
    await DataSave.setDouble('double', 3.14);

    expect(DataSave.getBool('bool'), isTrue);
    expect(DataSave.getInt('int'), 42);
    expect(DataSave.getDouble('double'), 3.14);
  });

  test('returns null for missing or invalid values', () async {
    await DataSave.setString('invalid-int', 'not-a-number');
    await DataSave.setString('invalid-bool', 'not-a-bool');

    expect(DataSave.getString('missing'), isNull);
    expect(DataSave.getInt('invalid-int'), isNull);
    expect(DataSave.getBool('invalid-bool'), isNull);
  });

  test('removeAll removes stored values', () async {
    await DataSave.setString('first', 'one');
    await DataSave.setString('second', 'two');
    await DataSave.setLargeString('large', 'three');

    await DataSave.removeAll();

    expect(DataSave.getString('first'), isNull);
    expect(DataSave.getString('second'), isNull);
    expect(DataSave.getLargeString('large'), isNull);
  });

  test('stores strings larger than the cookie limit', () async {
    final value = List<String>.filled(12000, 'x').join();

    await DataSave.setLargeString('large-json', value);

    expect(DataSave.getLargeString('large-json'), value);
  });

  test('keeps cookie and large storage namespaces separate', () async {
    await DataSave.setString('same-key', 'cookie');
    await DataSave.setLargeString('same-key', 'local-storage');

    expect(DataSave.getString('same-key'), 'cookie');
    expect(DataSave.getLargeString('same-key'), 'local-storage');

    expect(await DataSave.remove('same-key'), isTrue);
    expect(DataSave.getLargeString('same-key'), isNull);
    expect(DataSave.getString('same-key'), isNull);
  });
}
