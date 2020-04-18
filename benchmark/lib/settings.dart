import 'dart:math';

import 'package:flutter/material.dart';

enum Mode { wake, read, write, delete }
enum Storage { single, multi, ether }

class BenchmarkSettings {
  var uiLock = true;
  var useAES = false;

  var modes = <Mode, bool>{
    Mode.wake: true,
    Mode.read: true,
    Mode.write: true,
    Mode.delete: false,
  }; // what to benchmark
  void addMode(Mode mode) => modes[mode] = true;
  void delMode(Mode mode) => modes[mode] = false;
  void flipMode(Mode mode) => modes[mode] = !modes[mode];

  var storages = <Storage, bool>{
    Storage.single: true,
    Storage.multi: true,
    Storage.ether: true,
  }; //where to benchmark
  void addStorage(Storage storage) => storages[storage] = true;
  void delStorage(Storage storage) => storages[storage] = false;
  void flipStorage(Storage storage) => storages[storage] = !storages[storage];

  final blocCountRange = RangeValues(0, 50);
  final blocCountDivs = 10;
  var blocCount = RangeValues(5, 35); // just amt (0-50)
  RangeLabels get blocCountLabels => RangeLabels(
        '${blocCount.start.toInt()}',
        '${blocCount.end.toInt()}',
      );

  // int64 size is 4 bytes
  // string char 2 or 4 bytes
  final stateSizeRange = RangeValues(2, 22);
  final stateSizeDivs = 10;
  var stateSize = RangeValues(2, 8); // 2^n size (0-20)
  RangeLabels get stateSizeLabels => RangeLabels(
        _format(stateSize.start.toInt()),
        _format(stateSize.end.toInt()),
      );
  int get stateSizeBytesMax => _convert(stateSize.end);
  int _convert(double e) => pow(2, e).toInt();
  String _format(int size) {
    final e = size % 10;
    final p = const ['Bytes', 'KB', 'MB', 'GB'][size ~/ 10];
    return '${pow(2, e)} $p';
  }
}
