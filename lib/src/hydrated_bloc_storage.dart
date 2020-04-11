import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart' as p;

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

/// An abstraction over generic instantaneous storage
/// ([read]|[write]|[delete]|[clear]|[keys]) will take place
/// in current `Isolate`'s event-loop
abstract class InstantStorage<T> {
  /// Returns value or null for key
  T read(String key);

  /// Persists key value pair
  T write(String key, T value);

  /// Deletes key value pair
  T delete(String key);

  /// Clears all key value pairs from storage
  void clear();

  /// Iterable of keys
  Iterable<String> get keys;
}

/// An abstraction over generic asynchronous storage
/// ([read]|[write]|[delete]|[clear]|[tokens]) will take place
/// in future `Isolate`'s event-loop
abstract class FutureStorage<T> {
  /// Returns record for key
  Future<T> read(String token);

  /// Persists record for token
  Future<T> write(String token, T record);

  /// Deletes record for token
  Future<T> delete(String token);

  /// Clears all records storage
  Future<void> clear();

  /// Stream with registered tokens
  Stream<String> get tokens;
}

//TODO REAL

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
  static HydratedBlocStorage _instance;
  final InstantStorage<dynamic> _cache;
  final FutureStorage<String> _storage;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
  }) async {
    if (_instance != null) {
      return _instance;
    }
    storageDirectory ??= await getTemporaryDirectory();
    final storage = HydratedFutureStorage(storageDirectory);
    _instance = await getInstanceWith(storage: storage);
    return _instance;
  }

  /// Returns an instance of [HydratedBlocStorage].
  /// You can provide custom ([cache]|[storage]),
  /// otherwise default implementation will be used.
  /// Default [InstantStorage] is just in-memory `Map`
  /// Default [FutureStorage] uses `getTemporaryDirectory`
  /// for storing file per `HydratedBloc`'s `storageToken`
  static Future<HydratedBlocStorage> getInstanceWith({
    InstantStorage<dynamic> cache,
    FutureStorage<String> storage,
  }) async {
    if (_instance != null) {
      return _instance;
    }
    cache ??= _HydratedInstantStorage();
    storage ??= HydratedFutureStorage(await getTemporaryDirectory());
    _instance = HydratedBlocStorage._(cache, storage);
    await _instance._infuse();
    return _instance;
  }

  HydratedBlocStorage._(this._cache, this._storage);

  // Used to fill in-memory cache
  // Corrupted files are removed
  Future<void> _infuse() => _storage.tokens.asyncMap((token) async {
        try {
          final string = await _storage.read(token);
          final object = json.decode(string);
          return _cache.write(token, object);
        } on dynamic catch (_) {
          await _storage.delete(token);
        }
      }).drain();

  /// Returns cached value by key
  dynamic read(String key) {
    return _cache.read(key);
  }

  /// Persists key value pair
  Future<void> write(String key, dynamic value) async {
    _cache.write(key, value);
    await _storage.write(key, json.encode(value));
    return _cache.write(key, value);
  }

  /// Deletes key value pair
  Future<void> delete(String key) async {
    _cache.delete(key);
    return await _storage.delete(key);
  }

  /// Clears all key value pairs
  /// managed by `this` storage
  Future<void> clear() async {
    _cache.clear();
    _instance = null;
    return await _storage.clear();
  }
}

/// Default [InstantStorage] for `HydratedBloc`
class _HydratedInstantStorage extends _InstantStorage<dynamic> {}

class _InstantStorage<T> extends InstantStorage<T> {
  final Map<String, T> _map = <String, T>{};

  @override
  T read(String key) => _map[key];

  @override
  T write(String key, T value) => _map[key] = value;

  @override
  T delete(String key) => _map[key] = null;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;
}

/// Default [FutureStorage] for `HydratedBloc`
class HydratedFutureStorage extends FutureStorage<String> {
  /// `Directory` for files to be managed in
  final Directory directory;

  /// Create `HydratedFutureStorage` working in [directory]
  HydratedFutureStorage(this.directory);

  // Tokens are keys to `File` objects
  final InstantStorage<File> _files = _InstantStorage<File>();

  static const String _prefix = '.bloc.';
  String _token(String path) => p.split(path).last.split('.')[2];
  String _path(String token) => p.join(directory.path, '$_prefix$token.json');
  File _fileByToken(String token) =>
      _files.read(token) ?? _files.write(token, File(_path(token)));

  // Returns null if file was not found
  Future<File> _find(String token) async {
    final file = _fileByToken(token);
    return (await file.exists()) ? file : null;
  }

  @override
  Stream<String> get tokens => directory
      .list()
      .where((item) => item is File)
      .map((file) => file.path)
      .where((path) => path.contains(_prefix))
      .map(_token);

  @override
  Future<String> read(String token) async =>
      (await _find(token))?.readAsString();

  @override
  Future<String> write(String token, String record) async {
    final file = await _fileByToken(token).writeAsString(record);
    return file.readAsString();
  }

  @override
  Future<String> delete(String token) async {
    var file = _files.read(token);
    if (file == null) return null;
    file = await _find(token);
    if (file == null) return null;
    final record = await file.readAsString();
    await file.delete();
    _files.delete(token);
    return record;
  }

  // Intentionally deletes only cached files
  @override
  Future<void> clear() => Stream.fromIterable(_files.keys)
      .asyncMap(_find)
      .where((file) => file != null)
      .asyncMap((file) => file.delete())
      .drain();
}

//TODO TEMP
class HydratedSingleStorageTEMP extends HydratedStorage {
  static final Lock _lock = Lock();
  final Map<String, dynamic> _storage;
  final File _file;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<HydratedSingleStorageTEMP> getInstance({
    Directory storageDirectory,
  }) {
    return _lock.synchronized(() async {
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

      return HydratedSingleStorageTEMP._(storage, file);
    });
  }

  HydratedSingleStorageTEMP._(this._storage, this._file);

  @override
  dynamic read(String key) {
    return _storage[key];
  }

  @override
  Future<void> write(String key, dynamic value) {
    return _lock.synchronized(() {
      _storage[key] = value;
      return _file.writeAsString(json.encode(_storage));
    });
  }

  @override
  Future<void> delete(String key) {
    return _lock.synchronized(() {
      _storage[key] = null;
      return _file.writeAsString(json.encode(_storage));
    });
  }

  @override
  Future<void> clear() {
    return _lock.synchronized(
      () async {
        _storage.clear();
        if (await _file.exists()) {
          await _file.delete();
        }
      },
    );
  }
}
