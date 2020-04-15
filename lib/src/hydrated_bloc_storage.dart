import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
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
abstract class TokenStorage<T> {
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
  static final Lock _lock = Lock();
  final Map<String, dynamic> _storage;
  final File _file;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<HydratedBlocStorage> getInstance({
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

      return HydratedBlocStorage._(storage, file);
    });
  }

  HydratedBlocStorage._(this._storage, this._file);

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

class Duplex extends HydratedStorage {
  final InstantStorage<dynamic> _cache;
  final TokenStorage<String> _storage;

  // /// Returns an instance of `HydratedBlocStorage`.
  // /// `storageDirectory` can optionally be provided.
  // /// By default, `getTemporaryDirectory` is used.
  // static Future<Duplex> getInstance({
  //   Directory storageDirectory,
  // }) async {
  //   storageDirectory ??= await getTemporaryDirectory();
  //   final storage = await SinglefileStorage.getInstance(storageDirectory);
  //   final instance = await getInstanceWith(storage: storage);
  //   return instance;
  // }

  /// Returns an instance of [HydratedBlocStorage].
  /// You can provide custom ([cache]|[storage]),
  /// otherwise default implementation will be used.
  /// Default [InstantStorage] is just in-memory `Map`
  /// Default [TokenStorage] uses `getTemporaryDirectory`
  /// for storing file per `HydratedBloc`'s `storageToken`
  static Future<Duplex> getInstanceWith({
    InstantStorage<dynamic> cache,
    TokenStorage<String> storage,
  }) async {
    cache ??= _HydratedInstantStorage();
    storage ??= await Multiplexer(await getTemporaryDirectory());
    final instance = Duplex._(cache, storage);
    await instance._infuse();
    return instance;
  }

  Duplex._(this._cache, this._storage);

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
/// Default [TokenStorage] for `HydratedBloc`
/// [SinglefileStorage] - all blocs to single file
/// [Multiplexer] - file per bloc
/// [EtherealStorage] - does nothing, used to in-memory blocs
class Multiplexer extends TokenStorage<String> {
  /// `Directory` for files to be managed in
  final Directory directory;

  /// Create `MultifileStorage` utilizing [directory]
  Multiplexer(this.directory);

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

/// Consumes `FutureStorage` to be `FutureStorage`
class AESDecorator extends TokenStorage<String> {
  final TokenStorage<Uint8List> _storage;
  final Encrypter _encrypter;

  /// AESDecorator is an encryption layer.
  /// Pack it with BinaryStorage
  /// And provide password string
  AESDecorator({String pass, TokenStorage<Uint8List> storage})
      : _storage = storage,
        _encrypter = Encrypter(AES(
          Key(sha256.convert(utf8.encode(pass)).bytes),
        ));

  // factory AESDecorator.password(
  //     {String pass, TokenStorage<Uint8List> storage}) = AESDecorator;

  @override
  Stream<String> get tokens => _storage.tokens;

  @override
  Future<String> read(String token) async {
    final pair = await _storage.read(token);
    final iv = IV(pair.sublist(0, 16));
    final encrypted = Encrypted(pair.sublist(16));
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  @override
  Future<String> write(String token, String record) async {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(record, iv: iv);
    final pair = Uint8List.fromList(iv.bytes + encrypted.bytes);
    await _storage.write(token, pair);
    return record;
  }

  @override
  Future<void> delete(String token) => _storage.delete(token);

  @override
  Future<void> clear() => _storage.clear();
}

/// Adapts `StringStorage` to be `BinaryStorage`
class Base64Adapter extends TokenStorage<Uint8List> {
  final TokenStorage<String> _storage;

  /// Load it with `MultifileStorage`
  /// for example
  Base64Adapter(this._storage);

  @override
  Stream<String> get tokens => _storage.tokens;

  @override
  Future<Uint8List> read(String token) async {
    final b64 = await _storage.read(token);
    return base64.decode(b64);
  }

  @override
  Future<Uint8List> write(String token, Uint8List record) async {
    final b64 = base64.encode(record);
    await _storage.write(token, b64);
    return record;
  }

  @override
  Future<void> delete(String token) => _storage.delete(token);

  @override
  Future<void> clear() => _storage.clear();
}

/// Default [TokenStorage] for `HydratedBloc`
/// [SinglefileStorage] - all blocs to single file
///  [Multiplexer] - file per bloc
///   [EtherealStorage] - does nothing, used to in-memory blocs
class SinglefileStorage extends HydratedStorage {
  static final Lock _lock = Lock(); // TODO simplify
  final Map<String, dynamic> _storage;
  final File _file;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<SinglefileStorage> getInstance({
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

      return SinglefileStorage._(storage, file);
    });
  }

  SinglefileStorage._(this._storage, this._file);

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

/// Used in combination with `HydratedBlocStorage` cache
/// to achieve in-memory storage behavior.
// TODO Temporal
class EtherealStorage extends TokenStorage<String> {
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
