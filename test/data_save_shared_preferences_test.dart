import 'package:data_save/DataSave.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await DataSave.init();
  });

  test(
    'stores string lists as native preferences and preserves their values',
    () async {
      final values = <String>['Dart', 'فارسی; value=100% ✓', '', 'Dart'];

      await DataSave.setStringList('favorites', values);

      final preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      expect(preferences.getStringList('favorites'), values);
      expect(DataSave.getStringList('favorites'), values);

      values.add('unsaved');
      DataSave.getStringList('favorites')!.clear();
      expect(DataSave.getStringList('favorites'), [
        'Dart',
        'فارسی; value=100% ✓',
        '',
        'Dart',
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
    'getKeys returns an independent snapshot of every stored type',
    () async {
      expect(DataSave.getKeys(), isEmpty);
      await DataSave.setString('کلید; =100%', 'text');
      await DataSave.setStringList('list', ['one']);
      await DataSave.setBool('bool', true);
      await DataSave.setInt('int', 42);
      await DataSave.setDouble('double', 3.14);
      await DataSave.setLargeString('large', 'text');

      final keys = DataSave.getKeys();
      expect(keys, {'کلید; =100%', 'list', 'bool', 'int', 'double', 'large'});

      expect(await DataSave.remove('list'), isTrue);
      expect(DataSave.getStringList('list'), isNull);
      expect(keys, contains('list'));
      expect(DataSave.getKeys(), isNot(contains('list')));
      keys.clear();
      expect(DataSave.getKeys(), isNotEmpty);

      await DataSave.removeAll();
      expect(DataSave.getKeys(), isEmpty);
    },
  );

  test('remove succeeds for an absent key and rejects an empty key', () async {
    await DataSave.setString('keep', 'value');

    expect(await DataSave.remove('missing'), isTrue);
    expect(await DataSave.remove(''), isFalse);
    expect(DataSave.getString('keep'), 'value');
  });

  test('stores large strings on native platforms', () async {
    final value = List<String>.filled(12000, 'x').join();

    await DataSave.setLargeString('large-json', value);

    expect(DataSave.getLargeString('large-json'), value);
  });

  test('uses the same storage as the normal API', () async {
    await DataSave.setString('same-key', 'normal');
    await DataSave.setLargeString('same-key', 'large');

    expect(DataSave.getString('same-key'), 'large');
    expect(DataSave.getLargeString('same-key'), 'large');

    expect(await DataSave.remove('same-key'), isTrue);
    expect(DataSave.getLargeString('same-key'), isNull);
    expect(DataSave.getString('same-key'), isNull);
  });

  test('removeAll clears both storage modes', () async {
    await DataSave.setString('normal', 'one');
    await DataSave.setLargeString('large', 'two');

    await DataSave.removeAll();

    expect(DataSave.getString('normal'), isNull);
    expect(DataSave.getLargeString('large'), isNull);
  });
}
