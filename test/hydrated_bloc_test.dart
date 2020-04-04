import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// This file contains:
/// tests for [HydratedBloc] see: [blocGroup]
///    [HydratedBlocStorage]  ->: [storageGroup]
///   [HydratedBlocDelegate]  ->: [delegateGroup]
/// as we have to run them from single main
/// as all of them do IO on the same file
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  blocGroup();
  storageGroup();
  delegateGroup();
}

/// `HydratedBloc` group infrastructure setup
/// ->: [blocGroup]
/// <-: [main]
class MockStorage extends Mock implements HydratedBlocStorage {}

class MockHydratedBlocDelegate extends Mock implements HydratedBlocDelegate {}

class MyUuidHydratedBloc extends HydratedBloc<String, String> {
  @override
  String get initialState => super.initialState ?? Uuid().v4();

  @override
  Stream<String> mapEventToState(String event) async* {}

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String fromJson(dynamic json) {
    try {
      return json['value'];
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

class MyHydratedBloc extends HydratedBloc<int, int> {
  @override
  int get initialState => super.initialState ?? 0;

  @override
  Stream<int> mapEventToState(int event) async* {}

  @override
  Map<String, int> toJson(int state) {
    return {'value': state};
  }

  @override
  int fromJson(dynamic json) {
    try {
      return json['value'] as int;
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

class MyMultiHydratedBloc extends HydratedBloc<int, int> {
  final String _id;

  MyMultiHydratedBloc(String id) : _id = id;

  @override
  int get initialState => super.initialState ?? 0;

  @override
  String get id => _id;

  @override
  Stream<int> mapEventToState(int event) async* {}

  @override
  Map<String, int> toJson(int state) {
    return {'value': state};
  }

  @override
  int fromJson(dynamic json) {
    try {
      return json['value'] as int;
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

/// `HydratedBloc` test group
/// <-: [main]
void blocGroup() {
  group('HydratedBloc', () {
    MockHydratedBlocDelegate delegate;
    MockStorage storage;

    setUp(() {
      delegate = MockHydratedBlocDelegate();
      BlocSupervisor.delegate = delegate;
      storage = MockStorage();

      when(delegate.storage).thenReturn(storage);
    });

    group('SingleHydratedBloc', () {
      MyHydratedBloc bloc;

      setUp(() {
        bloc = MyHydratedBloc();
      });

      test('stores initialState when instantiated', () {
        verify<dynamic>(
          storage.write('MyHydratedBloc', '{"value":0}'),
        ).called(1);
      });

      test('initialState should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyHydratedBloc')).thenReturn(null);
        expect(bloc.initialState, 0);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(2);
      });

      test('initialState should return 101 when fromJson returns 101', () {
        when<dynamic>(storage.read('MyHydratedBloc'))
            .thenReturn(json.encode({'value': 101}));
        expect(bloc.initialState, 101);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await bloc.clear();
          verify(storage.delete('MyHydratedBloc')).called(1);
        });
      });
    });

    group('MultiHydratedBloc', () {
      MyMultiHydratedBloc multiBlocA;
      MyMultiHydratedBloc multiBlocB;

      setUp(() {
        multiBlocA = MyMultiHydratedBloc('A');
        multiBlocB = MyMultiHydratedBloc('B');
      });

      test('initialState should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA')).thenReturn(null);
        expect(multiBlocA.initialState, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedBlocB')).thenReturn(null);
        expect(multiBlocB.initialState, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(2);
      });

      test('initialState should return 101/102 when fromJson returns 101/102',
          () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA'))
            .thenReturn(json.encode({'value': 101}));
        expect(multiBlocA.initialState, 101);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedBlocB'))
            .thenReturn(json.encode({'value': 102}));
        expect(multiBlocB.initialState, 102);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await multiBlocA.clear();
          verify(storage.delete('MyMultiHydratedBlocA')).called(1);
          verifyNever(storage.delete('MyMultiHydratedBlocB'));

          await multiBlocB.clear();
          verify(storage.delete('MyMultiHydratedBlocB')).called(1);
        });
      });
    });

    group('MyUuidHydratedBloc', () {
      test('stores initialState when instantiated', () {
        MyUuidHydratedBloc();
        verify<dynamic>(storage.write('MyUuidHydratedBloc', any)).called(1);
      });

      test('correctly caches computed initialState', () {
        String cachedState;
        when<dynamic>(storage.write('MyUuidHydratedBloc', any))
            .thenReturn(null);
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        cachedState = verify(storage.write('MyUuidHydratedBloc', captureAny))
            .captured
            .last;
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        final initialStateB =
            verify(storage.write('MyUuidHydratedBloc', captureAny))
                .captured
                .last;
        expect(initialStateB, cachedState);
      });
    });
  });
}

/// `HydratedBlocStorage` test group
/// <-: [main]
void storageGroup() {
  group('HydratedStorage', () {
    group('Default Storage Directory', () {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      var response = '.';
      HydratedBlocStorage hydratedStorage;

      channel.setMockMethodCallHandler((methodCall) async {
        return response;
      });

      tearDown(() async {
        await hydratedStorage.clear();
      });

      group('read', () {
        test('returns null when file does not exist', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(
            hydratedStorage.read('CounterBloc'),
            isNull,
          );
        });

        test('returns correct value when file exists', () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync(json.encode({
            "CounterBloc": {"value": 4}
          }));
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        });

        test(
            'returns null value'
            'when file exists but contains corrupt json and deletes the file',
            () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync("invalid-json");
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          expect(file.existsSync(), false);
        });
      });

      group('write', () {
        test('writes to file', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        });
      });

      group('clear', () {
        test('calls deletes file, clears storage, and resets instance',
            () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
          await hydratedStorage.clear();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          final file = File('./.hydrated_bloc.json');
          expect(file.existsSync(), false);
        });
      });

      group('delete', () {
        test('does nothing for non-existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();

          expect(hydratedStorage.read('CounterBloc'), null);
          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });

        test('deletes existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');

          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });
      });
    });

    group('Custom Storage Directory', () {
      HydratedBlocStorage hydratedStorage;

      tearDown(() async {
        await hydratedStorage.clear();
      });

      group('read', () {
        test('returns null when file does not exist', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(
            hydratedStorage.read('CounterBloc'),
            isNull,
          );
        });

        test('returns correct value when file exists', () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync(json.encode({
            "CounterBloc": {"value": 4}
          }));
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        });

        test(
            'returns null value'
            'when file exists but contains corrupt json and deletes the file',
            () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync("invalid-json");
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(hydratedStorage.read('CounterBloc'), isNull);
          expect(file.existsSync(), false);
        });
      });

      group('write', () {
        test('writes to file', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        });
      });

      group('heavy write', () {
        test('writes heavily to file', () async {
          final token = 'CounterBloc';
          final directory = Directory.current;
          final file = File('${directory.path}/.hydrated_bloc.json');
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: directory,
          );
          final tasks = Iterable.generate(150, (i) => i).map((i) async {
            final record = Iterable.generate(
              i,
              (i) => Iterable.generate(i, (j) => 'Point($i,$j);').toList(),
            ).toList();
            final jsoned = json.encode(record);
            hydratedStorage.write(token, jsoned); // no await here

            dynamic written;
            String string;
            try {
              string = await HydratedBlocStorage.lock.synchronized(() async {
                return await file.readAsString();
              });
              final object = json.decode(string);
              written = object;
            } on dynamic catch (_) {
              written = null;
              print(string);
            } // At least json is not corrupted
            expect(written, isNotNull);
            // expect(string, jsoned); // will definitely crash
          });

          await Future.wait(tasks);
        });
      });

      group('clear', () {
        test('calls deletes file, clears storage, and resets instance',
            () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
          await hydratedStorage.clear();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          final file = File('./.hydrated_bloc.json');
          expect(file.existsSync(), false);
        });
      });

      group('delete', () {
        test('does nothing for non-existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );

          expect(hydratedStorage.read('CounterBloc'), null);
          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });

        test('deletes existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');

          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });
      });
    });
  });
}

/// `HydratedBlocDelegate` group infrastructure setup
/// ->: [delegateGroup]
/// <-: [main]
class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {
  String get storageToken => '${runtimeType.toString()}$id';
}

/// `HydratedBlocDelegate` test group
/// <-: [main]
void delegateGroup() {
  group('HydratedDelegate', () {
    MockStorage storage;
    HydratedBlocDelegate delegate;
    MockBloc bloc;

    setUp(() {
      storage = MockStorage();
      delegate = HydratedBlocDelegate(storage);
      bloc = MockBloc();
    });

    tearDown(() async {
      await delegate.storage.clear();
    });

    test('should call storage.write when onTransition is called', () {
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      final expected = <String, String>{'nextState': 'json'};
      when(bloc.id).thenReturn('');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      verify(storage.write('MockBloc', json.encode(expected))).called(1);
    });

    test('should call storage.write when onTransition is called with bloc id',
        () {
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: 'nextState',
      );
      final expected = <String, String>{'nextState': 'json'};
      when(bloc.id).thenReturn('A');
      when(bloc.toJson('nextState')).thenReturn(expected);
      delegate.onTransition(bloc, transition);
      verify(storage.write('MockBlocA', json.encode(expected))).called(1);
    });

    group('Default Storage Directory', () {
      setUp(() async {
        const channel = MethodChannel('plugins.flutter.io/path_provider');
        var response = '.';

        channel.setMockMethodCallHandler((methodCall) async {
          return response;
        });
      });

      test(
          'should call storage.write'
          'when onTransition is called using the static build', () async {
        delegate = await HydratedBlocDelegate.build();
        final transition = Transition(
          currentState: 'currentState',
          event: 'event',
          nextState: 'nextState',
        );
        final expected = <String, String>{'nextState': 'json'};
        when(bloc.id).thenReturn('');
        when(bloc.toJson('nextState')).thenReturn(expected);
        delegate.onTransition(bloc, transition);
        expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
      });

      test(
          'should call storage.write'
          'when onTransition is called using the static build with bloc id',
          () async {
        delegate = await HydratedBlocDelegate.build();
        final transition = Transition(
          currentState: 'currentState',
          event: 'event',
          nextState: 'nextState',
        );
        final expected = <String, String>{'nextState': 'json'};
        when(bloc.id).thenReturn('A');
        when(bloc.toJson('nextState')).thenReturn(expected);
        delegate.onTransition(bloc, transition);
        expect(delegate.storage.read('MockBlocA'), '{"nextState":"json"}');
      });
    });

    group('Custom Storage Directory', () {
      test(
          'should call storage.write'
          'when onTransition is called using the static build', () async {
        delegate = await HydratedBlocDelegate.build(
          storageDirectory: Directory.current,
        );
        final transition = Transition(
          currentState: 'currentState',
          event: 'event',
          nextState: 'nextState',
        );
        final expected = <String, String>{'nextState': 'json'};
        when(bloc.id).thenReturn('');
        when(bloc.toJson('nextState')).thenReturn(expected);
        delegate.onTransition(bloc, transition);
        expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
      });

      test(
          'should call storage.write'
          'when onTransition is called using the static build with bloc id',
          () async {
        delegate = await HydratedBlocDelegate.build(
          storageDirectory: Directory.current,
        );
        final transition = Transition(
          currentState: 'currentState',
          event: 'event',
          nextState: 'nextState',
        );
        final expected = <String, String>{'nextState': 'json'};
        when(bloc.id).thenReturn('A');
        when(bloc.toJson('nextState')).thenReturn(expected);
        delegate.onTransition(bloc, transition);
        expect(delegate.storage.read('MockBlocA'), '{"nextState":"json"}');
      });
    });
  });
}
