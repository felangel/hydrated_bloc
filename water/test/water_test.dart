import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water/water.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('water', () {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    const response = '.';

    Water water;

    channel.setMockMethodCallHandler((call) async => response);

    tearDown(() => water.clear());

    group('read', () {
      test('returns null when file does not exist', () async {
        water = await Water.getInstance();
        expect(water.read('MockBloc'), isNull);
      });

      test('returns null value when corrupt', () async {
        water = await Water.getInstance();
        await water.write('invalid', 'value');
        expect(water.read('MockBloc'), isNull);
      });
    });

    group('write', () {
      test('writes value', () async {
        water = await Water.getInstance();
        await water.write('MockBloc', {'state': 1});
        expect(water.read('MockBloc')['state'] as int, 1);
      });
    });

    group('clear', () {
      test('calls deletes file, clears storage and resets instance', () async {
        water = await Water.getInstance();
        await water.write('MockBloc', {'state': 1});
        expect(water.read('MockBloc'), {'state': 1});

        await water.clear();
        expect(water.read('MockBloc'), isNull);

        final file = File('water.hive');
        expect(file.existsSync(), false);
      });
    });

    group('delete', () {
      test('does nothing for non-existing key value pair', () async {
        water = await Water.getInstance();

        expect(water.read('MockBloc'), null);
        await water.delete('MockBloc');
        expect(water.read('MockBloc'), isNull);
      });

      test('deletes existing key value pair', () async {
        water = await Water.getInstance();

        await water.write('MockBloc', {'state': 1});
        expect(water.read('MockBloc'), {'state': 1});

        await water.delete('MockBloc');
        expect(water.read('MockBloc'), isNull);
      });
    });
  });
}
