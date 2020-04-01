import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {}

class MockRuntimeHydratedBloc extends Mock
    implements RuntimeHydratedBloc<dynamic, dynamic> {}

class MockStorage extends Mock implements HydratedBlocStorage {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('HydratedBlocDelegate', () {
    MockStorage storage;
    HydratedBlocDelegate delegate;
    MockBloc bloc;
    MockRuntimeHydratedBloc runtimeHydratedBloc;

    setUp(() {
      storage = MockStorage();
      delegate = HydratedBlocDelegate(storage);
      bloc = MockBloc();
      runtimeHydratedBloc = MockRuntimeHydratedBloc();
    });

    tearDown(() async {
      final file = File('./.hydrated_bloc.json');
      if (file.existsSync()) {
        file.deleteSync();
      }
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

    test(
        'should store in the runtime storage when onTransition is called with runtime bloc',
        () {
      final expectedToken = 'dummyToken';
      final expectedState = 'nextState';
      final transition = Transition(
        currentState: 'currentState',
        event: 'event',
        nextState: expectedState,
      );
      when(runtimeHydratedBloc.storageToken).thenReturn(expectedToken);

      expect(delegate.runtimeStorage, isEmpty);

      delegate.onTransition(runtimeHydratedBloc, transition);
      expect(delegate.runtimeStorage[expectedToken], expectedState);
      expect(delegate.runtimeStorage.length, 1);
    });

    group('Default Storage Directory', () {
      setUp(() async {
        const channel = MethodChannel('plugins.flutter.io/path_provider');
        var response = '.';

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          return response;
        });
      });

      test(
          'should call storage.write when onTransition is called using the static build',
          () async {
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
          'should call storage.write when onTransition is called using the static build with bloc id',
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
          'should call storage.write when onTransition is called using the static build',
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
        when(bloc.id).thenReturn('');
        when(bloc.toJson('nextState')).thenReturn(expected);
        delegate.onTransition(bloc, transition);
        expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
      });

      test(
          'should call storage.write when onTransition is called using the static build with bloc id',
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
