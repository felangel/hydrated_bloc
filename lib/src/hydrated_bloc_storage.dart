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

// TODO make syncing between modes?
// To make switching non-breaking
/// Storage mode to run in
enum StorageMode {
  /// Save all states to same file
  singlefile,

  /// Allocate file per bloc
  multifile,

  /// In-memory storage, lost on restart
  temporal,
}

/// `StorageKey` is used to encrypt/decrypt saved data
class StorageKey {
  /// The key itself
  final Key key;

  /// Key from bytes
  StorageKey(Uint8List key) : key = Key(key);

  /// Key from regular list
  factory StorageKey.list(List<int> key) => StorageKey(key);

  /// Key from string password
  factory StorageKey.password(String pass) =>
      StorageKey(sha256.convert(utf8.encode(pass)).bytes);
}

/// This factory creates `StringCell`s
typedef CellFactory = StringCell Function(File file);

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
  final HydratedStorage _storage;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  /// `StorageMode` toggles between storages.
  /// If `StorageKey` is provided, storage becomes
  /// AES with PKCS7 padding in CTR mode secured.
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
    StorageMode mode = StorageMode.singlefile,
    StorageKey key,
  }) async {
    if (mode != StorageMode.temporal) {
      var cellFactory = (file) => StringCell(file);
      if (key != null) {
        final enc = Encrypter(AES(key.key));
        cellFactory = (file) => AESCell(BinaryCell(file), enc);
      }

      final directory = storageDirectory ?? await getTemporaryDirectory();
      if (mode == StorageMode.singlefile) {
        final cell = cellFactory(File('${directory.path}/.hydrated_bloc.json'));
        return HydratedBlocStorage._(await Singlet.instance(cell));
      }
      if (mode == StorageMode.multifile) {
        return HydratedBlocStorage._(await Duplex.instance(
          storage: CellMultiplexer(directory, cellFactory),
        ));
      }
    }
    return HydratedBlocStorage._(Temporal());
  }

  HydratedBlocStorage._(this._storage);

  @override
  dynamic read(String key) => _storage.read(key);

  @override
  Future<void> write(String key, dynamic value) => _storage.write(key, value);

  @override
  Future<void> delete(String key) => _storage.delete(key);

  @override
  Future<void> clear() => _storage.clear();
}

/// `Duplex` is a combination of `InstantStorage` and `TokenStorage`
class Duplex extends HydratedStorage {
  final InstantStorage<dynamic> _cache;
  final FutureStorage<String> _storage;

  /// Returns an instance of [HydratedBlocStorage].
  /// You can provide custom ([cache]|[storage]),
  /// otherwise default implementation will be used.
  /// Default [InstantStorage] is just in-memory `Map`
  /// Default [FutureStorage] uses `getTemporaryDirectory`
  /// for storing file per `HydratedBloc`'s `storageToken`
  static Future<Duplex> instance({
    InstantStorage<dynamic> cache,
    FutureStorage<String> storage,
  }) async {
    cache ??= _HydratedInstantStorage();
    storage ??= await CellMultiplexer(
      await getTemporaryDirectory(),
      (file) => StringCell(file),
    );
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

/// `Singlet` is a duplex lol of `StringCell` and cache
class Singlet extends HydratedStorage {
  static final _lock = Lock();
  final Map<String, dynamic> _cache;
  final StringCell _cell;

  /// Returns an instance of `Singlet`
  /// Persists values to `StringCell`
  /// If cell is null acts as `TemporalStorage`
  static Future<Singlet> instance(StringCell cell) {
    return _lock.synchronized(() async {
      var cache = <String, dynamic>{};

      if (await cell.exists()) {
        try {
          cache = json.decode(await cell.read()) as Map<String, dynamic>;
        } on dynamic catch (_) {
          await cell.delete();
        }
      }

      return Singlet._(cache, cell);
    });
  }

  Singlet._(this._cache, this._cell);

  @override
  dynamic read(String key) {
    return _cache[key];
  }

  @override
  Future<void> write(String key, dynamic value) {
    return _lock.synchronized(() {
      _cache[key] = value;
      return _cell.write(json.encode(_cache));
    });
  }

  @override
  Future<void> delete(String key) {
    return _lock.synchronized(() {
      _cache[key] = null;
      return _cell.write(json.encode(_cache));
    });
  }

  @override
  Future<void> clear() {
    return _lock.synchronized(
      () async {
        _cache.clear();
        if (await _cell.exists()) {
          await _cell.delete();
        }
      },
    );
  }
}

/// Default [FutureStorage] for `HydratedBloc`
/// [SinglefileStorage] - all blocs to single file
/// [CellMultiplexer] - file per bloc
/// [TemporalStorage] - does nothing, used to in-memory blocs
class CellMultiplexer extends FutureStorage<String> {
  /// `Directory` for cells to be managed in
  final Directory directory;
  final CellFactory _factory;

  /// Create `CellMultiplexer` utilizing [directory]
  CellMultiplexer(this.directory, this._factory);

  // Tokens are keys to `StringCell` objects
  final InstantStorage<StringCell> _cells = _InstantStorage<StringCell>();

  static final _locks = _InstantStorage<Lock>();
  Lock _lockByToken(String token) => // wanted to use cells as locks but
      _locks.read(token) ?? _locks.write(token, Lock()); // locks must be static

  static const String _prefix = '.bloc.';
  String _token(String path) => p.split(path).last.split('.')[2];
  String _path(String token) => p.join(directory.path, '$_prefix$token.json');
  StringCell _cellByToken(String token) =>
      _cells.read(token) ?? _cells.write(token, _factory(File(_path(token))));

  // Returns null if cell was not found
  Future<StringCell> _find(String token) async {
    final cell = _cellByToken(token);
    return (await cell.exists()) ? cell : null;
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
      .synchronized(() async => (await _find(token))?.read());

  @override
  Future<String> write(String token, String record) =>
      _lockByToken(token).synchronized(() async {
        await _cellByToken(token).write(record);
        return record;
      });

  @override
  Future<void> delete(String token) =>
      _lockByToken(token).synchronized(() async {
        var cell = _cells.read(token);
        if (cell == null) return null;
        cell = await _find(token);
        if (cell == null) return null;
        await cell.delete();
        _cells.delete(token);
      });

  @override
  Future<void> clear() => Stream.fromIterable(_cells.keys)
      .asyncMap((token) => _lockByToken(token).synchronized(
            () async => (await _find(token))?.delete(),
          )) // Intentionally deletes only cached cells,
      .drain(); // cells multiplexer worked with
}

/// `BinaryCell` is a cell which stores binary contents
class BinaryCell {
  final File _file;

  /// Creates `BinaryCell` object
  BinaryCell(this._file);

  ///Checks whether the cell exists
  Future<bool> exists() => _file.exists();

  /// Read cell contents
  Future<Uint8List> read() => _file.readAsBytes();

  /// Write to cell
  Future<void> write(Uint8List bytes) => _file.writeAsBytes(bytes);

  /// Delete cell
  Future<void> delete() => _file.delete();
}

/// `StringCell` is a cell which stores text contents
/// I need this abstraction against `File` object to
/// wrap it with AESCell and other decorators later.
class StringCell {
  final File _file;

  /// Creates `BinaryCell` object
  StringCell(this._file);

  ///Checks whether the cell exists
  Future<bool> exists() => _file.exists();

  /// Read cell contents
  Future<String> read() => _file.readAsString();

  /// Write to cell
  Future<void> write(String contents) => _file.writeAsString(contents);

  /// Delete cell
  Future<void> delete() => _file.delete();
}

/// `AESCell` encrypts it's data with `Encrypter`.
/// Has `StringCell` api outside
/// and `BinaryCell` api inside.
class AESCell implements StringCell {
  final BinaryCell _cell;
  final Encrypter _encrypter;

  /// Create `AESCell` with `Encrypter`
  AESCell(this._cell, this._encrypter);

  @override
  File get _file => _cell._file;

  @override
  Future<bool> exists() => _cell.exists();

  @override
  Future<String> read() async {
    final pair = await _cell.read();
    final iv = IV(pair.sublist(0, 16));
    final encrypted = Encrypted(pair.sublist(16));
    final decrypted = _encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  @override
  Future<void> write(String contents) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(contents, iv: iv);
    final pair = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return _cell.write(pair);
  }

  @override
  Future<void> delete() => _cell.delete();
}

/// Achieves in-memory storage behavior.
class Temporal extends HydratedStorage {
  final InstantStorage<dynamic> _cache = _HydratedInstantStorage();

  @override
  dynamic read(String key) => _cache.read(key);

  @override
  Future<void> write(String key, dynamic value) async =>
      _cache.write(key, value);

  @override
  Future<void> delete(String key) async => _cache.delete(key);

  @override
  Future<void> clear() async => _cache.clear();
}
