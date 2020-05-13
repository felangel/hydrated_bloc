import 'dart:math' show Random, pow, sqrt;
import 'package:benchmark/settings.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import 'runner.dart';
import 'runners.dart';

class Result {
  final BenchmarkRunner runner;
  final Mode mode;
  Duration intTime;
  Duration intTimeErr;
  Duration stringTime;
  Duration stringTimeErr;
  double complete;

  Result(this.runner, this.mode);

  bool compare(Result other) {
    return runner.storage == other.runner.storage && mode == other.mode;
  }

  Result copy() {
    return Result(runner, mode)
      ..intTime = intTime
      ..stringTime = stringTime
      ..complete = complete;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storage': runner.storageType.toString(),
      'mode': mode.toString(),
      'aes': runner.aes,
      'intMeanMicroseconds': intTime.inMicroseconds,
      'intSDMicroseconds': intTimeErr.inMicroseconds,
      'stringMeanMicroseconds': stringTime.inMicroseconds,
      'stringSDMicroseconds': stringTimeErr.inMicroseconds,
    };
  }
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
      Storage.hive: HiveRunner(),
    };
    _runners =
        rr.keys.where((s) => settings.storages[s]).map((s) => rr[s]).toList();
  }

  int get totalIter => 16;
  List<BenchmarkRunner> _runners;

  Stream<Result> run() async* {
    final res = <Result>[];
    for (var i = 1; i <= totalIter; i++) {
      yield* _run(i).map((r) {
        res.add(r);
        r = r.copy();
        final sample = res.where((x) => r.compare(x));
        final ints = sample.map((x) => x.intTime);
        final strs = sample.map((x) => x.stringTime);
        r.intTime = mean(ints);
        r.stringTime = mean(strs);
        r.intTimeErr = stdErr(ints);
        r.stringTimeErr = stdErr(strs);
        return r;
      });
    }
  }

  Duration mean(Iterable<Duration> sample) {
    final sum = sample.reduce((val, x) => val + x);
    final count = sample.length;
    final mean = Duration(microseconds: sum.inMicroseconds ~/ count);
    return mean;
  }

  Duration stdErr(Iterable<Duration> sample) {
    if (sample.length < 2) return null;
    final av = mean(sample).inMicroseconds;
    final dispersion = sample
            .map((x) => x.inMicroseconds)
            .map((x) => x - av)
            .map((x) => pow(x, 2))
            .reduce((val, x) => val + x) /
        (sample.length - 1);
    final sd = sqrt(dispersion) / sqrt(sample.length);
    return Duration(microseconds: sd.toInt());
  } // standard deviation

  Stream<Result> _run(int iter) async* {
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

      final curIter = iter / totalIter;
      wake.complete = curIter;
      write.complete = curIter;
      read.complete = curIter;

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
