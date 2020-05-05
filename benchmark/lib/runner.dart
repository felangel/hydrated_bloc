import 'package:benchmark/settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class BenchmarkRunner {
  bool get aes;
  bool get b64;
  Storage get storageType;
  Future<HydratedStorage> get storageFactory;

  HydratedStorage storage;

  Future<void> setUp() async {
    storage = await storageFactory;
  }

  Future<void> tearDown() async {
    await storage.clear();
  }

  Future<Duration> batchWake() async {
    final s = Stopwatch()..start();
    await setUp();
    s.stop();
    return s.elapsed;
  }

  Future<Duration> batchRead(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      storage.read(key);
    }
    s.stop();
    return s.elapsed;
  }

  Future<Duration> batchWrite(Map<String, dynamic> entries) async {
    final s = Stopwatch()..start();
    for (var key in entries.keys) {
      await storage.write(key, entries[key]);
    }
    s.stop();
    return s.elapsed;
  }

  Future<Duration> batchDelete(List<String> keys) async {
    final s = Stopwatch()..start();
    for (var key in keys) {
      await storage.delete(key);
    }
    s.stop();
    return s.elapsed;
  }
}
