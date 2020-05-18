# 4.0.0

- Updated to `bloc: ^4.0.0` and `flutter_bloc: ^4.0.0`
- `onTransition` moved from `HydratedBlocDelegate` to `HydratedBloc`

# 3.1.0

- Persist `initialState` when initialized (thanks to [@orsenkucher](https://github.com/orsenkucher)).
- Fix: add `synchronized` to prevent file corruption (thanks to [@orsenkucher](https://github.com/orsenkucher))
- Refactor `HydratedBlocStorage.getInstance` to avoid using singleton (thanks to [@orsenkucher](https://github.com/orsenkucher))
- Upgrade to `path_provider: ^1.6.5`
- Fix: invoke `onError` and continue emitting states when exceptions occur

# 3.0.0

- Updated to `bloc: ^3.0.0`

# 3.0.0-dev.1

- Updated to `bloc: ^3.0.0-dev.1`

# 2.0.0

- Update to `bloc ^2.0.0`
- Adhere to [effective dart](https://dart.dev/guides/language/effective-dart)

# 1.1.0

- Optional `storageDirectory` can be provided ([#28](https://github.com/felangel/hydrated_bloc/issues/28)).
- Documentation Updates

# 1.0.0

- Update to bloc `v1.0.0`
- Documentation Updates

# 0.8.0

- Update to bloc `v0.16.0`
- Documentation Updates

# 0.7.0

- Desktop support via [path_provider_fde](https://github.com/google/flutter-desktop-embedding/tree/master/plugins/flutter_plugins/path_provider_fde) ([#24](https://github.com/felangel/hydrated_bloc/pull/24)).
- Documentation and Example Updates

# 0.6.0

- Support clearing individual `HydratedBloc` caches ([#21](https://github.com/felangel/hydrated_bloc/issues/21))
- Documentation and Example Updates

# 0.5.0

- Support for Desktop ([#18](https://github.com/felangel/hydrated_bloc/pull/18))
- Documentation and Example Updates

# 0.4.1

- Update to support optional `id` in cases where there are multiple instances of the same `HydratedBloc`
- Documentation Updates

# 0.4.0

- Update to bloc `v0.15.0`
- Documentation Updates

# 0.3.2

- Minor Updates to Package Dependencies
- Documentation Updates

# 0.3.1

- Add guards to `HydratedBlocStorage` to prevent exception if cache is corrupt.

# 0.3.0

- Update `HydratedBlocStorage` to use `getTemporaryDirectory` instead of `getApplicationDocumentsDirectory`
- Documentation Updates

# 0.2.1

- Bugfix to handle `Blocs` alongside `HydrateBlocs` within the same application.
- `toJson` can return `null` to avoid persisting the state change

# 0.2.0

- Upated `HydrateBlocDelegate` to have a static `build`
- Updated `toJson` and `fromJson` to eliminate the need to call `json.encode` and `json.decode` explicitly.
- `HydratedBlocSharedPreferences` replaced with `HydratedBlocStorage`
- Removed dependency on `SharedPreferences`
- Documentation Updates

# 0.1.0

- Renamed `HydratedBlocSharedPreferences` to `HydratedSharedPreferences`
- Documentation Updates

# 0.0.3

Added `clear` to `HydratedBlocStorage` API and Documentation Updates

# 0.0.2

Documentation Updates

# 0.0.1

Initial Version of the library.

Includes:

- `HydratedBloc`
- `HydratedBlocDelegate`
- `HydratedBlocSharedPreferences`
