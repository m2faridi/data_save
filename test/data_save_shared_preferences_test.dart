import 'package:data_save/DataSave.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await DataSave.init();
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

    await DataSave.remove('same-key');
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
