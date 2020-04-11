import 'package:benchmark/settings.dart';

abstract class BenchmarkRunner {
  // String get name;
  Storage get storageType;

  Future<void> setUp();
  Future<void> tearDown();

  Future<int> batchWakeInt();
  Future<int> batchWakeString();

  Future<int> batchReadInt(List<String> keys);
  Future<int> batchReadString(List<String> keys);

  Future<int> batchWriteInt(Map<String, int> entries);
  Future<int> batchWriteString(Map<String, String> entries);

  Future<int> batchDeleteInt(List<String> keys);
  Future<int> batchDeleteString(List<String> keys);
}
