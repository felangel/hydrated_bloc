import 'package:benchmark/settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water/water.dart';

import 'runner.dart';

class SinglefileRunner extends BenchmarkRunner {
  final pass = 'I should benchmark benchmark. Meta benchmarking bro';
  final bool aes;
  final bool b64;
  SinglefileRunner(this.aes, this.b64);

  @override
  Storage get storageType => Storage.single;

  @override
  Future<HydratedStorage> get storageFactory async {
    StorageKey key;
    if (aes) key = StorageKey.password(pass);
    final dir = await getTemporaryDirectory();
    return HydratedBlocStorage.getInstance(
      storageDirectory: dir,
      mode: StorageMode.singlefile,
      useBase64Cells: b64,
      key: key,
    );
  }
}

class MultifileRunner extends BenchmarkRunner {
  final pass = 'I should benchmark benchmark. Meta benchmarking bro';
  final bool aes;
  final bool b64;
  MultifileRunner(this.aes, this.b64);

  @override
  Storage get storageType => Storage.multi;

  @override
  Future<HydratedStorage> get storageFactory async {
    StorageKey key;
    if (aes) key = StorageKey.password(pass);
    final dir = await getTemporaryDirectory();
    return HydratedBlocStorage.getInstance(
      storageDirectory: dir,
      mode: StorageMode.multifile,
      useBase64Cells: b64,
      key: key,
    );
  }
}

class HiveRunner extends BenchmarkRunner {
  final pass = 'I should benchmark benchmark. Meta benchmarking bro';
  final bool aes = true;
  final bool b64 = false;

  @override
  Storage get storageType => Storage.hive;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    // Hive.generateSecureKey();
    return Water.getInstance(storageDirectory: dir, pass: pass);
  }
}
