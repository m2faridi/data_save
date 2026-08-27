@TestOn('browser')
library;

import 'package:data_save/DataSave.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await DataSave.init();
    await DataSave.removeAll();
  });

  tearDown(DataSave.removeAll);

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

    await DataSave.remove('same-key');
    expect(DataSave.getLargeString('same-key'), isNull);
    expect(DataSave.getString('same-key'), isNull);
  });
}
