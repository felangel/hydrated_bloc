import 'package:benchmark/settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'runner.dart';

class SingleFileRunner extends BenchmarkRunner {
  @override
  Storage get storageType => Storage.single;

  @override
  Future<HydratedStorage> get storageFactory async {
    final dir = await getTemporaryDirectory();
    return HydratedBlocStorage.getInstance(storageDirectory: dir);
  }
}
