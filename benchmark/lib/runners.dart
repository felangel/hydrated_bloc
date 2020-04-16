import 'package:benchmark/settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'runner.dart';

class SinglefileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.single;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    return HydratedBlocStorage.getInstance(
      storageDirectory: dir,
      mode: StorageMode.singlefile,
    );
  }
}

class MultifileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.multi;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    return HydratedBlocStorage.getInstance(
      storageDirectory: dir,
      mode: StorageMode.multifile,
    );
  }
}

// TODO restore Temporal here
class EtherealfileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.ether;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    final key = StorageKey.password(
      'I should benchmark benchmark. Meta benchmarking bro',
    );
    return HydratedBlocStorage.getInstance(
      storageDirectory: dir,
      mode: StorageMode.multifile, //TODO temporal
      key: key,
    );
  }
}
