import 'dart:io';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'water.dart';

/// A variant of [HydratedBlocDelegate] which can build
/// a [Water] instance using `build()`
class WaterDelegate extends HydratedBlocDelegate {
  /// Constructs a [WaterDelegate] object with the optional [storage]
  WaterDelegate(HydratedStorage storage) : super(storage);

  /// Builds a [WaterDelegate] with an instance of [Water],
  /// optionally using the [storageDirectory] parameter
  static Future<WaterDelegate> build({Directory storageDirectory}) async =>
      WaterDelegate(await Water.getInstance(storageDirectory: storageDirectory));
}
