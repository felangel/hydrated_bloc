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

/// Storage mode to run in
enum StorageMode {
  /// Save all states to same file
  singlefile,

  /// Allocate file per bloc
  multifile,

  /// In-memory storage, lost on restart
  temporal,
}

/// `StorageKey` is used to encrypt/decrypt stored data
class StorageKey {
  /// The key itself
  final Key key;

  /// Key from bytes
  StorageKey(Uint8List key) : key = Key(key);

  /// Key from regular list
  factory StorageKey.list(List<int> list) =>
      StorageKey(Uint8List.fromList(list));

  /// Key from string password
  factory StorageKey.password(String pass) =>
      StorageKey(sha256.convert(utf8.encode(pass)).bytes);
}

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
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
    bool safeSync = true,
    bool useBase64Cells = false, // TODO refactoring desirable
  }) async {
    // TODO get singletons back, as Storages are now separate from `this`
    if (mode != StorageMode.temporal) {
      // ignore: omit_local_variable_types
      CellFactory cellFactory = (file) => StringCell(file);
      if (key != null) {
        final enc = Encrypter(AES(key.key));
        cellFactory = !useBase64Cells // OTRICALA here😭
            ? (file) => AESCell(BinaryCell(file), enc)
            : (file) => AESCell(Base64Cell(StringCell(file)), enc);
      }

      final directory = storageDirectory ?? await getTemporaryDirectory();
      if (mode == StorageMode.singlefile) {
        return HydratedBlocStorage._(await Duplex.instance(
          await CellSinglet.instance(directory, cellFactory),
        ));
      }
      if (mode == StorageMode.multifile) {
        return HydratedBlocStorage._(await Duplex.instance(
          CellMultiplexer(directory, cellFactory),
        ));
      }
    }
    return HydratedBlocStorage._(Temporal());
  }

  final HydratedStorage _storage;
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

/// Achieves in-memory storage behavior.
/// Type instance of `HydratedStorage`.
class Temporal extends HydratedStorage {
  final InstantStorage<dynamic> _cache = _InstantStorage<dynamic>();

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

/// `Duplex` is a duplex of `InstantStorage` and `FutureStorage`.
/// Type instance of `HydratedStorage`.
class Duplex extends HydratedStorage {
  /// Instantiates `Duplex` of default cache
  /// and provided `FutureStorage<String>`.
  static Future<Duplex> instance(FutureStorage<String> storage) async {
    final instance = Duplex._(storage);
    await instance._infuse();
    return instance;
  }

  final InstantStorage<dynamic> _cache = _InstantStorage<dynamic>();
  final FutureStorage<String> _storage;
  Duplex._(this._storage);

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

/// This factory creates `StringCell`s
typedef CellFactory = StringCell Function(File file);

/// `CellMultiplexer` - is file per bloc `FutureStorage<String>`
class CellMultiplexer extends FutureStorage<String> {
  /// Create `CellMultiplexer` utilizing `Directory`
  /// `CellFactory` is used to produce `StringCell`s
  CellMultiplexer(this._directory, this._factory);

  final Directory _directory;
  final CellFactory _factory;

  // Tokens are keys to `StringCell` objects
  final InstantStorage<StringCell> _cells = _InstantStorage<StringCell>();

  static final _locks = _InstantStorage<Lock>();
  Lock _lockByToken(String token) => // wanted to use cells as locks but
      _locks.read(token) ?? _locks.write(token, Lock()); // locks must be static

  static const String _prefix = '.bloc.';
  String _token(String path) => p.split(path).last.split('.')[2];
  String _path(String token) => p.join(_directory.path, '$_prefix$token.json');
  StringCell _cellByToken(String token) =>
      _cells.read(token) ?? _cells.write(token, _factory(File(_path(token))));

  // Returns null if cell was not found
  Future<StringCell> _find(String token) async {
    final cell = _cellByToken(token);
    return (await cell.exists()) ? cell : null;
  }

  @override
  Stream<String> get tokens => _directory
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
      .drain(); // cell multiplexer worked with
}

/// `CellSinglet` is a one-file `FutureStorage<String>`.
class CellSinglet extends FutureStorage<String> {
  static final _lock = Lock();
  final Map<String, String> _cache;
  final StringCell _cell;

  /// Returns an instance of `CellSinglet`.
  /// `CellFactory` is used to produce
  /// one `StringCell` inside `Directory`.
  static Future<CellSinglet> instance(
    Directory directory,
    CellFactory cellFactory,
  ) {
    return _lock.synchronized(() async {
      final cell = cellFactory(File('${directory.path}/.hydrated_bloc.json'));
      var storage = <String, String>{};

      if (await cell.exists()) {
        try {
          final storageJson = json.decode(await cell.read());
          storage = (storageJson as Map).cast<String, String>();
        } on dynamic catch (_) {
          await cell.delete();
        }
      }

      return CellSinglet._(storage, cell);
    });
  }

  CellSinglet._(this._cache, this._cell);

  @override
  Stream<String> get tokens => Stream.fromIterable(_cache.keys);

  @override
  Future<String> read(String token) {
    return Future.value(_cache[token]);
  }

  @override
  Future<String> write(String token, String value) {
    return _lock.synchronized(() async {
      _cache[token] = value;
      await _cell.write(json.encode(_cache));
      return value;
    });
  }

  @override
  Future<void> delete(String token) {
    return _lock.synchronized(() {
      _cache[token] = null;
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

/// `StringCell` is a cell which stores text contents.
/// I need this abstraction against `File` object to
/// wrap it with `AESCell` and other decorators later.
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

/// Adapts `StringCell` to be `BinaryCell`
class Base64Cell implements BinaryCell {
  final StringCell _cell;

  /// Creates `Base64Cell` adapter
  Base64Cell(this._cell);

  @override
  File get _file => _cell._file;

  @override
  Future<bool> exists() => _cell.exists();
  @override
  Future<Uint8List> read() async {
    final b64 = await _cell.read();
    return base64.decode(b64);
  }

  @override
  Future<void> write(Uint8List bytes) {
    final b64 = base64.encode(bytes);
    return _cell.write(b64);
  }

  @override
  Future<void> delete() => _cell.delete();
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
