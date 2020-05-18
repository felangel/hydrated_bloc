import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import '../hydrated_bloc.dart';

/// {@template hydratedblocdelegate}
/// A specialized `BlocDelegate` which handles persisting state changes
/// transparently and asynchronously.
/// {@endtemplate}
class HydratedBlocDelegate extends BlocDelegate {
  /// Instance of `HydratedStorage` used to manage persisted states.
  final HydratedStorage storage;

  /// Builds a new instance of `HydratedBlocDelegate` with the
  /// default [HydratedBlocStorage].
  /// A custom [storageDirectory] can optionally be provided.
  ///
  /// This is the recommended way to use a `HydratedBlocDelegate`.
  /// If you want to customize `HydratedBlocDelegate`
  /// you can extend `HydratedBlocDelegate` and perform the necessary overrides.
  ///
  /// [encryptionCipher] is Hive's `HiveCipher`,
  /// You can provide default one using following snippet:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// import 'package:hive/hive.dart';
  ///
  /// const password = 'hydration';
  /// final byteskey = sha256.convert(utf8.encode(pass)).bytes;
  /// return HiveAesCipher(byteskey);
  /// ```
  static Future<HydratedBlocDelegate> build({
    Directory storageDirectory,
    HiveCipher encryptionCipher,
  }) async {
    return HydratedBlocDelegate(
      await HydratedBlocStorage.getInstance(
        storageDirectory: storageDirectory,
        encryptionCipher: encryptionCipher,
      ),
    );
  }

  /// {@macro hydratedblocdelegate}
  HydratedBlocDelegate(this.storage);
}
