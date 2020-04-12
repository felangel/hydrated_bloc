import 'package:benchmark/settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class BenchmarkRunner {
  Storage get storageType;
  Future<HydratedStorage> get storageFactory;

  HydratedStorage storage;

  Future<void> setUp() async {
    storage = await storageFactory;
  }

  Future<void> tearDown() async {
    storage.clear();
  }

  Future<int> batchWakeInt() async {
    final s = Stopwatch()..start();
    await setUp();
    s.stop();
    return s.elapsedMilliseconds;
  }

  Future<int> batchWakeString() => batchWakeInt();

  Future<int> batchReadInt(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      storage.read(key);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  Future<int> batchReadString(List<String> keys) => batchReadInt(keys);

  Future<int> batchWriteString(Map<String, dynamic> entries) async {
    final s = Stopwatch()..start();
    for (var key in entries.keys) {
      await storage.write(key, entries[key]);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  Future<int> batchWriteInt(Map<String, int> entries) =>
      batchWriteString(entries);

  Future<int> batchDeleteInt(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      await storage.delete(key);
    }
    s.stop();
    return s.elapsedMilliseconds;
  }

  Future<int> batchDeleteString(List<String> keys) => batchDeleteInt(keys);
}
