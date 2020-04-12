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
  void delete(String key);

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
  Future<void> delete(String token);

  /// Clears all records storage
  Future<void> clear();

  /// Stream with registered tokens
  Stream<String> get tokens;
}

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
  final InstantStorage<dynamic> _cache;
  final FutureStorage<String> _storage;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
  }) async {
    storageDirectory ??= await getTemporaryDirectory();
    final storage = MultifileStorage(storageDirectory);
    final instance = await getInstanceWith(storage: storage);
    return instance;
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
    cache ??= _HydratedInstantStorage();
    storage ??= MultifileStorage(await getTemporaryDirectory());
    final instance = HydratedBlocStorage._(cache, storage);
    await instance._infuse();
    return instance;
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
  Future<void> write(String key, dynamic value) {
    _cache.write(key, value);
    return _storage.write(key, json.encode(value));
  }

  /// Deletes key value pair
  Future<void> delete(String key) {
    _cache.delete(key);
    return _storage.delete(key);
  }

  /// Clears all key value pairs
  /// managed by `this` storage
  Future<void> clear() {
    _cache.clear();
    return _storage.clear();
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
  void delete(String key) => _map[key] = null;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;
}

// HydratedFutureStorage
/// Default [FutureStorage] for `HydratedBloc`
/// [SinglefileStorage] - all blocs to single file
///  [MultifileStorage] - file per bloc
///   [EtherealStorage] - does nothing, used to in-memory blocs
class MultifileStorage extends FutureStorage<String> {
  /// `Directory` for files to be managed in
  final Directory directory;

  /// Create `MultifileStorage` utilizing [directory]
  MultifileStorage(this.directory);

  // Tokens are keys to `File` objects
  final InstantStorage<File> _files = _InstantStorage<File>();

  static final _locks = _InstantStorage<Lock>();
  Lock _lockByToken(String token) => // wanted to use files as locks but
      _locks.read(token) ?? _locks.write(token, Lock()); // locks must be static

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
  Future<String> read(String token) => _lockByToken(token)
      .synchronized(() async => (await _find(token))?.readAsString());

  @override
  Future<String> write(String token, String record) =>
      _lockByToken(token).synchronized(() async {
        await _fileByToken(token).writeAsString(record);
        return record;
      });

  @override
  Future<void> delete(String token) =>
      _lockByToken(token).synchronized(() async {
        var file = _files.read(token);
        if (file == null) return null;
        file = await _find(token);
        if (file == null) return null;
        await file.delete();
        _files.delete(token);
      });

  @override
  Future<void> clear() => Stream.fromIterable(_files.keys)
      .asyncMap((token) => _lockByToken(token).synchronized(
            () async => (await _find(token))?.delete(),
          )) // Intentionally deletes only cached files
      .drain(); // files storage worked with
}

/// Default [FutureStorage] for `HydratedBloc`
/// [SinglefileStorage] - all blocs to single file
///  [MultifileStorage] - file per bloc
///   [EtherealStorage] - does nothing, used to in-memory blocs
class SinglefileStorage extends FutureStorage<String> {
  static final Lock _lock = Lock();
  final Map<String, String> _cache;
  final File _file;

  /// Returns an instance of `SinglefileStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<SinglefileStorage> getInstance({
    Directory storageDirectory,
  }) {
    return _lock.synchronized(() async {
      final directory = storageDirectory ?? await getTemporaryDirectory();
      final file = File('${directory.path}/.hydrated_bloc.json');
      var storage = <String, String>{};

      if (await file.exists()) {
        try {
          storage =
              json.decode(await file.readAsString()) as Map<String, String>;
        } on dynamic catch (_) {
          await file.delete();
        }
      }

      return SinglefileStorage._(storage, file);
    });
  }

  SinglefileStorage._(this._cache, this._file);

  @override
  Stream<String> get tokens => Stream.fromIterable(_cache.keys);

  @override
  Future<String> read(String token) {
    return Future.value(_cache[token]);
  }

  @override
  Future<String> write(String token, dynamic value) {
    return _lock.synchronized(() async {
      _cache[token] = value;
      await _file.writeAsString(json.encode(_cache));
      return value;
    });
  }

  @override
  Future<void> delete(String token) {
    return _lock.synchronized(() {
      _cache[token] = null;
      return _file.writeAsString(json.encode(_cache));
    });
  }

  @override
  Future<void> clear() {
    return _lock.synchronized(
      () async {
        _cache.clear();
        if (await _file.exists()) {
          await _file.delete();
        }
      },
    );
  }
}

/// Used in combination with `HydratedBlocStorage` cache
/// to achieve in-memory storage behavior.
class EtherealStorage extends FutureStorage<String> {
  /// Creates an instance of `EtherealStorage`.
  EtherealStorage();
  @override
  Stream<String> get tokens => Stream.empty();
  @override
  Future<String> read(String token) => Future.value();
  @override
  Future<String> write(String token, dynamic value) => Future.value(value);
  @override
  Future<void> delete(String token) => Future.value();
  @override
  Future<void> clear() => Future.value();
}
