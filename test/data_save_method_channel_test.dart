import 'dart:async';

import 'package:data_save/DataSave.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Map<String, Object> stored;
  late List<MethodCall> calls;
  Completer<bool>? pendingClear;
  PlatformException? clearError;

  setUp(() {
    SharedPreferences.resetStatic();
    stored = {
      for (var i = 0; i < 1000; i++) 'flutter.key-$i': 'value-$i',
      'native.setting': 'keep',
    };
    calls = [];
    pendingClear = null;
    clearError = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      final arguments = call.arguments as Map<Object?, Object?>?;
      final prefix = arguments?['prefix'] as String? ?? 'flutter.';
      final allowList = arguments?['allowList'] as List<Object?>?;
      bool matches(String key) =>
          key.startsWith(prefix) &&
          (allowList == null || allowList.contains(key));

      switch (call.method) {
        case 'getAll':
        case 'getAllWithParameters':
          return {
            for (final entry in stored.entries)
              if (matches(entry.key)) entry.key: entry.value,
          };
        case 'remove':
          stored.remove(arguments!['key']);
          return true;
        case 'clear':
        case 'clearWithParameters':
          if (clearError != null) throw clearError!;
          if (pendingClear != null) await pendingClear!.future;
          stored.removeWhere((key, _) => matches(key));
          return true;
        default:
          throw StateError('Unexpected method: ${call.method}');
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  test(
    'clears 1000 preferences in one backend call and preserves unrelated data',
    () async {
      await DataSave.init();
      calls.clear();

      await DataSave.removeAll();

      expect(calls.map((call) => call.method), ['clear']);
      expect(DataSave.getKeys(), isEmpty);
      expect(stored, {'native.setting': 'keep'});
    },
  );

  test('removeAllLarge uses the same bulk clear on native platforms', () async {
    await DataSave.init();
    calls.clear();

    await DataSave.removeAllLarge();

    expect(calls.map((call) => call.method), ['clear']);
    expect(stored, {'native.setting': 'keep'});
  });

  test('bulk clear respects a custom prefix and allowList', () async {
    SharedPreferences.setPrefix('app.', allowList: {'app.remove'});
    stored = {
      'app.remove': 'value',
      'app.keep': 'value',
      'other.keep': 'value',
    };
    await DataSave.init();

    await DataSave.removeAll();

    expect(DataSave.getKeys(), isEmpty);
    expect(stored, {'app.keep': 'value', 'other.keep': 'value'});
  });

  test('removeAll waits for the backend to finish clearing', () async {
    await DataSave.init();
    pendingClear = Completer<bool>();
    var completed = false;

    final removal = DataSave.removeAll().then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    expect(stored, contains('flutter.key-0'));

    pendingClear!.complete(true);
    await removal;
    expect(completed, isTrue);
    expect(stored, {'native.setting': 'keep'});
  });

  test('removeAll propagates backend errors', () async {
    await DataSave.init();
    clearError = PlatformException(code: 'disk-error');

    await expectLater(DataSave.removeAll(), throwsA(isA<PlatformException>()));
    expect(stored, contains('flutter.key-0'));
  });
}
