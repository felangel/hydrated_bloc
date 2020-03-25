import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// {@template hydratedblocdelegate}
/// A specialized `BlocDelegate` which handles persisting state changes
/// transparently and asynchronously.
/// {@endtemplate}
class HydratedBlocDelegate extends BlocDelegate {
  /// Instance of `HydratedStorage` used to manage persisted states.
  final HydratedStorage storage;

  /// Builds a new instance of `HydratedBlocDelegate` with the
  /// default `HydratedBlocStorage`.
  /// A custom `storageDirectory` can optionally be provided.
  ///
  /// This is the recommended way to use a `HydratedBlocDelegate`.
  /// If you want to customize `HydratedBlocDelegate` you can extend `HydratedBlocDelegate`
  /// and perform the necessary overrides.
  static Future<HydratedBlocDelegate> build({
    Directory storageDirectory,
  }) async {
    return HydratedBlocDelegate(
      await HydratedBlocStorage.getInstance(storageDirectory: storageDirectory),
    );
  }

  /// Builds a new instance of `HydratedBlocDelegate` with
  /// `HydratedBlocStorage`'s default implementations of
  /// [InstantStorage] cache and [FutureStorage] permanent storage.
  /// You can slide the default [HydratedFutureStorage] with
  /// custom storage `Directory` into this builder.
  ///
  /// Otherwise you can implement your own ([cache]|[storage]).
  /// Explore our [HydratedFutureStorage] for more implementation details.
  ///
  /// This is straightforward, yet agile way to use a `HydratedBlocDelegate`,
  /// though you can extend and make your own.
  static Future<HydratedBlocDelegate> buildWith({
    InstantStorage<dynamic> cache,
    FutureStorage<String> storage,
  }) async {
    return HydratedBlocDelegate(
      await HydratedBlocStorage.getInstanceWith(cache: cache, storage: storage),
    );
  }

  /// {@macro hydratedblocdelegate}
  HydratedBlocDelegate(this.storage);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    final state = transition.nextState;
    if (bloc is HydratedBloc) {
      final stateJson = bloc.toJson(state);
      if (stateJson != null) {
        storage.write(
          '${bloc.runtimeType.toString()}${bloc.id}',
          json.encode(stateJson),
        );
      }
    }
  }
}
