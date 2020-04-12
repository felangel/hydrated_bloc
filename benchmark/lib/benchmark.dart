import 'dart:math' show Random;
import 'package:benchmark/settings.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'runner.dart';
import 'runners.dart';

class Result {
  final BenchmarkRunner runner;
  Duration intTime;
  Duration stringTime;
  Mode mode;

  Result(this.runner);
}

class Benchmark {
  Benchmark(this.settings);

  final BenchmarkSettings settings;
  List<BenchmarkRunner> get _runners {
    final rr = {
      Storage.single: SinglefileRunner(),
      Storage.multi: MultifileRunner(),
      Storage.ether: EtherealfileRunner(),
    };
    return rr.keys
        .where((s) => settings.storages[s])
        .map((s) => rr[s])
        .toList();
  }

  List<Result> _createResults() {
    return _runners.map((r) => Result(r)).toList();
  }

  Map<String, List<int>> generateIntEntries(int count) {
    final map = <String, List<int>>{};
    final random = Random();
    final uuid = Uuid();
    final intcount = settings.stateSizeBytesMax ~/ 4;
    for (var i = 0; i < count; i++) {
      final key = uuid.v4();
      map[key] = Iterable.generate(
        intcount,
        (_) => random.nextInt(1 << 32),
      ).toList();
    }
    return map;
  }

  Map<String, String> generateStringEntries(int count) {
    final map = <String, String>{};
    final uuid = Uuid();
    final charcount = settings.stateSizeBytesMax ~/ 4;
    for (var i = 0; i < count; i++) {
      final key = uuid.v4();
      final val = randomString(randomBetween(0, charcount));
      map[key] = val;
    }
    return map;
  }

  Stream<Result> doReads() async* {
    final count = settings.blocCount.end.toInt();
    final results = _createResults();

    final intEntries = generateIntEntries(count);
    final intKeys = intEntries.keys.toList()..shuffle();

    final stringEntries = generateStringEntries(count);
    final stringKeys = stringEntries.keys.toList()..shuffle();

    for (var result in results) {
      result.mode = Mode.read;
      await result.runner.setUp();

      await result.runner.batchWrite(intEntries);
      result.intTime = await result.runner.batchRead(intKeys);

      await result.runner.batchWrite(stringEntries);
      result.stringTime = await result.runner.batchRead(stringKeys);

      await result.runner.tearDown();
      yield result;
    }
  }

  Stream<Result> doWakes() async* {
    final count = settings.blocCount.end.toInt();
    final results = _createResults();

    final intEntries = generateIntEntries(count);
    final stringEntries = generateStringEntries(count);

    for (var result in results) {
      result.mode = Mode.wake;
      await result.runner.setUp();
      await result.runner.batchWrite(intEntries);
      result.intTime = await result.runner.batchWake();
      await result.runner.tearDown();

      await result.runner.setUp();
      await result.runner.batchWrite(stringEntries);
      result.stringTime = await result.runner.batchWake();
      await result.runner.tearDown();

      yield result;
    }
  }

  Stream<Result> doWrites() async* {
    final count = settings.blocCount.end.toInt();
    final results = _createResults();
    final intEntries = generateIntEntries(count);
    final stringEntries = generateStringEntries(count);

    for (var result in results) {
      result.mode = Mode.write;
      await result.runner.setUp();

      result.intTime = await result.runner.batchWrite(intEntries);
      result.stringTime = await result.runner.batchWrite(stringEntries);

      await result.runner.tearDown();
      yield result;
    }
  }

  Future<List<Result>> doDeletes() async {
    final count = settings.blocCount.end.toInt();
    final results = _createResults();

    final intEntries = generateIntEntries(count);
    final intKeys = intEntries.keys.toList()..shuffle();
    for (var result in results) {
      result.mode = Mode.delete;
      await result.runner.setUp();
      await result.runner.batchWrite(intEntries);
      result.intTime = await result.runner.batchDelete(intKeys);
    }

    final stringEntries = generateStringEntries(count);
    final stringKeys = stringEntries.keys.toList()..shuffle();
    for (var result in results) {
      await result.runner.batchWrite(stringEntries);
      result.stringTime = await result.runner.batchDelete(stringKeys);
    }

    for (var result in results) {
      await result.runner.tearDown();
    }

    return results;
  }
}
