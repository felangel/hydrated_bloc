import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';

import '../hydrated_bloc.dart';
import 'platform/platform.dart';

/// A specialized `BlocDelegate` which handles persisting state changes
/// transparently and asynchronously.
class HydratedBlocDelegate extends BlocDelegate {
  /// Instance of `HydratedStorage` used to manage persisted states.
  final HydratedStorage storage;

  /// Builds a new instance of `HydratedBlocDelegate` with the
  /// default `HydratedBlocStorage`.
  ///
  /// This is the recommended way to use a `HydratedBlocDelegate`.
  /// If you want to customize `HydratedBlocDelegate` you can extend `HydratedBlocDelegate`
  /// and perform the necessary overrides.
  static Future<HydratedBlocDelegate> build([
    MockedPlatform platform,
  ]) async {
    return HydratedBlocDelegate(
      await HydratedBlocStorage.getInstance(platform),
    );
  }

  HydratedBlocDelegate(this.storage);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    final dynamic state = transition.nextState;
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
