import 'dart:async';
import 'dart:convert';

import 'directory/directory.dart';
import 'platform/platform.dart';

/// Interface which `HydratedBlocDelegate` uses to persist and retrieve
/// state changes from the local device.
abstract class HydratedStorage {
  /// Returns value for key
  dynamic read(String key);

  /// Persists key value pair
  Future<void> write(String key, dynamic value);

  /// Clears all key value pairs from storage
  Future<void> clear();
}

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage implements HydratedStorage {
  static const String _hydratedBlocStorageName = '.hydrated_bloc.json';
  static HydratedBlocStorage _instance;
  Map<String, dynamic> _storage;
  DirUtils _dir;

  /// Returns an instance of `HydratedBlocStorage`.
  static Future<HydratedBlocStorage> getInstance([MockedPlatform platform]) async {
    if (_instance != null) {
      return _instance;
    }
    final dirUtils = DirUtils(_hydratedBlocStorageName, platform);
    Map<String, dynamic> storage = Map<String, dynamic>();

    if (await dirUtils.fileExists()) {
      try {
        storage =
            json.decode(await dirUtils.readFile()) as Map<String, dynamic>;
      } catch (_) {
        await dirUtils.clear();
      }
    }

    _instance = HydratedBlocStorage._(storage, dirUtils);
    return _instance;
  }

  HydratedBlocStorage._(this._storage, this._dir);

  @override
  dynamic read(String key) {
    return _storage[key];
  }

  @override
  Future<void> write(String key, dynamic value) async {
    _storage[key] = value;
    await _dir.writeFile(json.encode(_storage));
    return _storage[key] = value;
  }

  @override
  Future<void> clear() async {
    _storage = Map<String, dynamic>();
    _instance = null;
    return await _dir.fileExists() ? await _dir.clear() : null;
  }
}
