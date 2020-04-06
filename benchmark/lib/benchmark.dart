import 'dart:math' show Random;
import 'package:random_string/random_string.dart';

import 'runner.dart';
import 'signlefile.dart';

class Result {
  final BenchmarkRunner runner;
  int intTime;
  int stringTime;

  Result(this.runner);
}

final _runners = [
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
  SingleFileRunner(),
];

List<Result> _createResults() {
  return _runners.map((r) => Result(r)).toList();
}

Map<String, int> generateIntEntries(int count) {
  final map = <String, int>{};
  final random = Random();
  for (var i = 0; i < count; i++) {
    final key = randomAlphaNumeric(randomBetween(5, 200));
    final val = random.nextInt(2 ^ 50);
    map[key] = val;
  }
  return map;
}

Map<String, String> generateStringEntries(int count) {
  final map = <String, String>{};
  for (var i = 0; i < count; i++) {
    final key = randomAlphaNumeric(randomBetween(5, 200));
    final val = randomString(randomBetween(5, 1000));
    map[key] = val;
  }
  return map;
}

Future<List<Result>> benchmarkRead(int count) async {
  final results = _createResults();

  final intEntries = generateIntEntries(count);
  final intKeys = intEntries.keys.toList()..shuffle();

  for (var result in results) {
    await result.runner.setUp();
    await result.runner.batchWriteInt(intEntries);
    result.intTime = await result.runner.batchReadInt(intKeys);
  }

  final stringEntries = generateStringEntries(count);
  final stringKeys = stringEntries.keys.toList()..shuffle();

  for (var result in results) {
    await result.runner.batchWriteString(stringEntries);
    result.stringTime = await result.runner.batchReadString(stringKeys);
  }

  for (var result in results) {
    await result.runner.tearDown();
  }

  return results;
}

Future<List<Result>> benchmarkWrite(int count) async {
  final results = _createResults();
  final intEntries = generateIntEntries(count);
  final stringEntries = generateStringEntries(count);

  for (var result in results) {
    await result.runner.setUp();
    result.intTime = await result.runner.batchWriteInt(intEntries);
    result.stringTime = await result.runner.batchWriteString(stringEntries);

    await result.runner.tearDown();
  }

  return results;
}

Future<List<Result>> benchmarkDelete(int count) async {
  final results = _createResults();

  final intEntries = generateIntEntries(count);
  final intKeys = intEntries.keys.toList()..shuffle();
  for (var result in results) {
    await result.runner.setUp();
    await result.runner.batchWriteInt(intEntries);
    result.intTime = await result.runner.batchDeleteInt(intKeys);
  }

  final stringEntries = generateStringEntries(count);
  final stringKeys = stringEntries.keys.toList()..shuffle();
  for (var result in results) {
    await result.runner.batchWriteString(stringEntries);
    result.stringTime = await result.runner.batchDeleteString(stringKeys);
  }

  for (var result in results) {
    await result.runner.tearDown();
  }

  return results;
}
