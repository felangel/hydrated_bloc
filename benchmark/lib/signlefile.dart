import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'runner.dart';

class SingleFileRunner implements BenchmarkRunner {
  @override
  String get name => 'single-file-storage';

  HydratedStorage storage;

  @override
  Future<void> setUp() async {
    final dir = await getTemporaryDirectory();
    storage = await HydratedBlocStorage.getInstance(storageDirectory: dir);
  }

  @override
  Future<void> tearDown() async {
    storage.clear();
  }

  @override
  Future<int> batchReadInt(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      storage.read(key);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  @override
  Future<int> batchReadString(List<String> keys) {
    return batchReadInt(keys); // implementation is the same for hive
  } // and honestly not only for hive

  @override
  Future<int> batchWriteString(Map<String, dynamic> entries) async {
    final s = Stopwatch()..start();
    for (var key in entries.keys) {
      await storage.write(key, entries[key]);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  @override
  Future<int> batchWriteInt(Map<String, int> entries) {
    return batchWriteString(entries);
  }

  @override
  Future<int> batchDeleteInt(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      await storage.delete(key);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  @override
  Future<int> batchDeleteString(List<String> keys) {
    return batchDeleteInt(keys);
  }
}
