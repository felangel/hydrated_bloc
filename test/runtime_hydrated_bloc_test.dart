import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';

class MockHydratedBlocDelegate extends Mock implements HydratedBlocDelegate {}

class MyRuntimeHydratedBloc extends RuntimeHydratedBloc<int, int> {
  @override
  int get initialState => super.initialState ?? 0;

  @override
  Stream<int> mapEventToState(int event) {
    return null;
  }
}

class MyMultiRuntimeHydratedBloc extends RuntimeHydratedBloc<int, int> {
  final String _id;

  MyMultiRuntimeHydratedBloc(String id) : _id = id;

  @override
  int get initialState => super.initialState ?? 0;

  @override
  String get id => _id;

  @override
  Stream<int> mapEventToState(int event) {
    return null;
  }
}

void main() {
  MockHydratedBlocDelegate delegate;
  Map<String, dynamic> runtimeStorage;

  setUp(() {
    delegate = MockHydratedBlocDelegate();
    BlocSupervisor.delegate = delegate;
    runtimeStorage = {};

    when(delegate.runtimeStorage).thenReturn(runtimeStorage);
  });

  group('RuntimeHydratedBloc', () {
    MyRuntimeHydratedBloc bloc;

    setUp(() {
      bloc = MyRuntimeHydratedBloc();
    });

    test('initialState should return 0 when map is empty', () {
      expect(bloc.initialState, 0);
    });

    test('initialState should return 101 when map contains 101', () {
      runtimeStorage[bloc.storageToken] = 101;
      expect(bloc.initialState, 101);
    });

    group('clear', () {
      test('calls delete map entry', () async {
        runtimeStorage[bloc.storageToken] = 101;
        bloc.clear();
        expect(runtimeStorage[bloc.storageToken], isNull);
      });
    });
  });

  group('MultiRuntimeHydratedBloc', () {
    MyMultiRuntimeHydratedBloc multiBlocA;
    MyMultiRuntimeHydratedBloc multiBlocB;

    setUp(() {
      multiBlocA = MyMultiRuntimeHydratedBloc('A');
      multiBlocB = MyMultiRuntimeHydratedBloc('B');
    });

    test('initialState should return 0 when map is empty', () {
      expect(multiBlocA.initialState, 0);
      expect(multiBlocB.initialState, 0);
    });

    test('initialState should return 101/102 when map contains 101/102', () {
      runtimeStorage[multiBlocA.storageToken] = 101;
      expect(multiBlocA.initialState, 101);

      runtimeStorage[multiBlocB.storageToken] = 102;
      expect(multiBlocB.initialState, 102);
    });

    group('clear', () {
      test('calls delete map entry', () async {
        runtimeStorage[multiBlocA.storageToken] = 101;
        runtimeStorage[multiBlocB.storageToken] = 102;
        multiBlocA.clear();
        expect(runtimeStorage[multiBlocA.storageToken], isNull);
        expect(runtimeStorage[multiBlocB.storageToken], isNotNull);
        multiBlocB.clear();
        expect(runtimeStorage[multiBlocB.storageToken], isNull);
      });
    });
  });
}
