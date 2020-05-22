import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
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

/// Abstract cipher can be implemented to customize encryption.
abstract class HydratedCipher implements HiveCipher {
  /// Calculate a hash of the key. Make sure to use a secure hash.
  int calculateKeyCrc();

  /// The maximum size the input can have after it has been encrypted.
  int maxEncryptedSize(Uint8List inp);

  /// Encrypt the given bytes.
  int encrypt(
      Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff);

  /// Decrypt the given bytes.
  int decrypt(
      Uint8List inp, int inpOff, int inpLength, Uint8List out, int outOff);
}

/// Default encryption algorithm. Uses AES256 CBC with PKCS7 padding.
class HydratedAesCipher extends HiveAesCipher implements HydratedCipher {
  /// Create a cipher with the given [key].
  HydratedAesCipher(List<int> key) : super(key);
}

/// Implementation of [HydratedStorage] which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
  /// Returns an instance of `HydratedBlocStorage`.
  /// [storageDirectory] can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  ///
  /// [encryptionCipher] is Hive's `HiveCipher`,
  /// You can provide default one using following snippet:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// import 'package:hive/hive.dart';
  ///
  /// const password = 'hydration';
  /// final byteskey = sha256.convert(utf8.encode(pass)).bytes;
  /// return HydratedAesCipher(byteskey);
  /// ```
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
    HydratedCipher encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) {
        return _instance;
      }

      final directory = storageDirectory ?? await getTemporaryDirectory();
      if (!kIsWeb) {
        Hive.init(directory.path);
      }

      final box = await Hive.openBox(
        'hydrated_box',
        encryptionCipher: encryptionCipher,
      );

      final singlet = await CellSinglet.instance(
        directory,
        (file) => StringCell(file),
      );

      final tokens = singlet.tokens;
      if (tokens.isNotEmpty) {
        for (final token in tokens) {
          try {
            final string = await singlet.read(token);
            final object = json.decode(string);
            await box.put(token, object);
          } on dynamic catch (_) {}
        }
        await singlet.clear();
      }

      return _instance = HydratedBlocStorage._(box);
    });
  }

  static final _lock = Lock();
  static HydratedStorage _instance;

  HydratedBlocStorage._(this._box);
  final Box _box;

  @override
  dynamic read(String key) {
    if (_box.isOpen) {
      return _box.get(key);
    } else {
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.put(key, value));
    } else {
      return null;
    }
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    } else {
      return null;
    }
  }

  @override
  Future<void> clear() {
    if (_box.isOpen) {
      _instance = null;
      return _lock.synchronized(_box.deleteFromDisk);
    } else {
      return null;
    }
  }
}

/// `CellSinglet` is storage of one file.
class CellSinglet {
  /// Returns an instance of `CellSinglet`.
  /// [cellFactory] is used to produce
  /// one [StringCell] inside [directory].
  static Future<CellSinglet> instance(
    Directory directory,
    CellFactory cellFactory,
  ) async {
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
  }

  CellSinglet._(this._cache, this._cell);
  final Map<String, String> _cache;
  final StringCell _cell;

  /// Iterable of registered tokens
  Iterable<String> get tokens => _cache.keys;

  /// Returns record for token
  String read(String token) {
    return _cache[token];
  }

  /// Voids all records
  Future<void> clear() async {
    _cache.clear();
    if (await _cell.exists()) {
      await _cell.delete();
    }
  }
}

/// `StringCell` is a cell which stores text contents.
class StringCell {
  final File _file;

  /// Creates `StringCell` object
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

/// This factory creates `StringCell`s
typedef CellFactory = StringCell Function(File file);
