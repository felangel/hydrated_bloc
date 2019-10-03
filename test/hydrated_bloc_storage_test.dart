import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  group('HydratedBlocStorage', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    String response = '.';
    HydratedBlocStorage hydratedStorage;

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return response;
    });

    tearDown(() {
      hydratedStorage.clear();
    });

    group('read', () {
      test('returns null when file does not exist', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance(testing: true);
        expect(
          hydratedStorage.read('CounterBloc'),
          isNull,
        );
      });

      test('returns correct value when file exists', () async {
        final directory =
            await HydratedBlocStorage.getDocumentDir(testing: true);
        final File file = HydratedBlocStorage.getFilePath(directory);
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(testing: true);
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
      });

      test(
          'returns null value when file exists but contains corrupt json and deletes the file',
          () async {
        final directory =
            await HydratedBlocStorage.getDocumentDir(testing: true);
        final File file = HydratedBlocStorage.getFilePath(directory);
        file.writeAsStringSync("invalid-json");
        hydratedStorage = await HydratedBlocStorage.getInstance(testing: true);
        expect(hydratedStorage.read('CounterBloc'), isNull);
        expect(file.existsSync(), false);
      });
    });

    group('write', () {
      test('writes to file', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance(testing: true);
        await Future.wait(<Future<void>>[
          hydratedStorage.write('CounterBloc', json.encode({"value": 4})),
        ]);

        expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
      });
    });

    group('clear', () {
      test('calls deletes file, clears storage, and resets instance', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance(testing: true);
        await Future.wait(<Future<void>>[
          hydratedStorage.write('CounterBloc', json.encode({"value": 4})),
        ]);

        expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        await hydratedStorage.clear();
        expect(hydratedStorage.read('CounterBloc'), isNull);
        final directory =
            await HydratedBlocStorage.getDocumentDir(testing: true);
        final File file = HydratedBlocStorage.getFilePath(directory);
        expect(file.existsSync(), false);
      });
    });
  });
}
