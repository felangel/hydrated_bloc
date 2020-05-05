import 'dart:math' show Random;
import 'package:benchmark/settings.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'runner.dart';
import 'runners.dart';

class Result {
  final BenchmarkRunner runner;
  final Mode mode;
  Duration intTime;
  Duration stringTime;

  Result(this.runner, this.mode);
}

class Entries {
  final BenchmarkSettings settings;
  Entries(this.settings) {
    final count = settings.blocCount.end.toInt();
    intEntries = generateIntEntries(count);
    intKeys = intEntries.keys.toList()..shuffle();
    stringEntries = generateStringEntries(count);
    stringKeys = stringEntries.keys.toList()..shuffle();
  }

  List<String> intKeys;
  List<String> stringKeys;
  Map<String, List<int>> intEntries;
  Map<String, String> stringEntries;

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
}

class Benchmark {
  final BenchmarkSettings settings;
  Benchmark(this.settings) {
    final aes = settings.useAES;
    final b64 = settings.useB64;
    final rr = {
      Storage.single: SinglefileRunner(aes, b64),
      Storage.multi: MultifileRunner(aes, b64),
      Storage.ether: EtherealfileRunner(),
    };
    _runners =
        rr.keys.where((s) => settings.storages[s]).map((s) => rr[s]).toList();
  }

  List<BenchmarkRunner> _runners;

  Stream<Result> run() async* {
    final modes = settings.modes;
    if (!modes.values.any((x) => x)) return;

    final entries = Entries(settings);
    final writes = <Result>[];
    final reads = <Result>[];

    for (var runner in _runners) {
      final wake = Result(runner, Mode.wake);
      final write = Result(runner, Mode.write);
      final read = Result(runner, Mode.read);

      await runner.setUp();
      write.intTime = await runner.batchWrite(entries.intEntries);
      if (modes[Mode.wake]) {
        wake.intTime = await runner.batchWake();
      }
      if (modes[Mode.read]) {
        read.intTime = await runner.batchRead(entries.intKeys);
      }

      await runner.tearDown();
      write.stringTime = await runner.batchWrite(entries.stringEntries);
      if (modes[Mode.wake]) {
        wake.stringTime = await runner.batchWake();
      }
      if (modes[Mode.read]) {
        read.stringTime = await runner.batchRead(entries.stringKeys);
      }
      // result.stringTime = await result.runner.batchDelete(keys);

      if (modes[Mode.wake]) yield wake;
      if (modes[Mode.write]) {
        if (modes[Mode.wake]) {
          writes.add(write);
        } else {
          yield write;
        }
      }
      if (modes[Mode.read]) reads.add(read);

      await runner.tearDown();
    }

    if (modes[Mode.wake]) yield* Stream.fromIterable(writes);
    yield* Stream.fromIterable(reads);
  }
}
