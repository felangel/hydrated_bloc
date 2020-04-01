import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// Specialized `Bloc` which handles initializing the `Bloc` state
/// based on the persisted state in memory.
abstract class RuntimeHydratedBloc<Event, State> extends Bloc<Event, State> {
  final Map<String, dynamic> _runtimeStorage =
      (BlocSupervisor.delegate as HydratedBlocDelegate).runtimeStorage;

  /// `storageToken` is used as registration token for hydrated storage.
  @nonVirtual
  String get storageToken => '${runtimeType.toString()}$id';

  @mustCallSuper
  @override
  State get initialState {
    try {
      return _runtimeStorage[storageToken] as State;
    } on dynamic catch (_) {
      return null;
    }
  }

  /// `id` is used to uniquely identify multiple instances of the same `RuntimeHydratedBloc` type.
  /// In most cases it is not necessary; however, if you wish to intentionally have multiple instances
  /// of the same `RuntimeHydratedBloc`, then you must override `id` and return a unique identifier for each
  /// `RuntimeHydratedBloc` instance in order to keep the caches independent of each other.
  String get id => '';

  /// `clear` is used to wipe or invalidate the cache of a `RuntimeHydratedBloc`.
  /// Calling `clear` will delete the cached state of the bloc
  /// but will not modify the current state of the bloc.
  void clear() => _runtimeStorage.remove(storageToken);
}
