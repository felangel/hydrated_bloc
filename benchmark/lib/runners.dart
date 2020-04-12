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
    final storage = await SinglefileStorage.getInstance(storageDirectory: dir);
    return HydratedBlocStorage.getInstanceWith(storage: storage);
  }
}

class MultifileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.multi;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    final storage = MultifileStorage(dir);
    return HydratedBlocStorage.getInstanceWith(storage: storage);
  }
}

class EtherealfileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.ether;

  @override
  Future<HydratedStorage> get storageFactory async {
    final storage = EtherealStorage();
    return HydratedBlocStorage.getInstanceWith(storage: storage);
  }
}
