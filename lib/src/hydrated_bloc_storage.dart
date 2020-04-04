import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

/// Interface which `HydratedBlocDelegate` uses to persist and retrieve
/// state changes from the local device.
abstract class HydratedStorage {
  /// Returns value for key
  dynamic read(String key);

  /// Persists key value pair
  Future<void> write(String key, dynamic value);

  /// Deletes key value pair
  Future<void> delete(String key);

  /// Clears all key value pairs from storage
  Future<void> clear();
}

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage implements HydratedStorage {
  static HydratedBlocStorage _instance;
  final Map<String, dynamic> _storage;
  final File _file;

  /// `Lock` is used to synchronize access to IO
  static final Lock lock = Lock();

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
  }) {
    return lock.synchronized(() async {
      if (_instance != null) {
        return _instance;
      }

      final directory = storageDirectory ?? await getTemporaryDirectory();
      final file = File('${directory.path}/.hydrated_bloc.json');
      var storage = <String, dynamic>{};

      if (await file.exists()) {
        try {
          storage =
              json.decode(await file.readAsString()) as Map<String, dynamic>;
        } on dynamic catch (_) {
          await file.delete();
        }
      }

      _instance = HydratedBlocStorage._(storage, file);
      return _instance;
    });
  }

  HydratedBlocStorage._(this._storage, this._file);

  @override
  dynamic read(String key) {
    return _storage[key];
  }

  @override
  Future<void> write(String key, dynamic value) {
    return lock.synchronized(() {
      _storage[key] = value;
      return _file.writeAsString(json.encode(_storage));
    });
  }

  @override
  Future<void> delete(String key) {
    return lock.synchronized(() {
      _storage[key] = null;
      return _file.writeAsString(json.encode(_storage));
    });
  }

  @override
  Future<void> clear() {
    return lock.synchronized(
      () async {
        _storage.clear();
        _instance = null;
        if (await _file.exists()) {
          await _file.delete();
        }
      },
    );
  }
}
