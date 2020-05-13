import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

/// Implementation of [HydratedStorage] which uses `PathProvider` and `Hive`
/// to persist and retrieve state changes from the local device.
class Water implements HydratedStorage {
  final Box _box;

  /// Returns an instance of [Water].
  /// [storageDirectory] can optionally be provided.
  /// By default, [Directory.current] is used.
  static Future<Water> getInstance({
    Directory storageDirectory,
    String pass,
  }) async {
    if (!kIsWeb) {
      final directory = storageDirectory ?? await getTemporaryDirectory();
      Hive.init(directory.path);
    }

    final box = await Hive.openBox(
      'water',
      encryptionKey: sha256.convert(utf8.encode(pass)).bytes,
    );

    final instance = Water._(box);
    return instance;
  }

  Water._(this._box);

  @override
  Future<void> clear() async {
    if (_box.isOpen) {
      return await _box.deleteFromDisk();
    } else {
      return null;
    }
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _box.delete(key);
    } else {
      return null;
    }
  }

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
      return _box.put(key, value);
    } else {
      return null;
    }
  }
}
