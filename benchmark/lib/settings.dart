import 'dart:math';

import 'package:flutter/material.dart';

enum Mode { wake, read, write, delete }
enum Storage { single, multi, ether }
enum Aspect { lock, mode, count, storage, size }

class BenchmarkSettings {
  var uiLock = true;
  var useAES = false;
  var useB64 = false;
  void flipUseAES() => useAES = !useAES;
  void flipUseB64() => useB64 = !useB64;

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

  final blocCountRange = RangeValues(1, 50);
  final blocCountDivs = 10;
  // get coef => (blocCountRange.end - blocCountRange.start) / blocCountDivs;
  static double adjust(double n) => 1 + n * 49 / 50;
  // var blocCount = RangeValues(5.9, 35.3); // just amt (0-50)
  var blocCount = RangeValues(adjust(5), adjust(35)); // just amt (0-50)
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

class SettingsModel extends InheritedModel<Aspect> {
  final BenchmarkSettings settings;
  const SettingsModel({
    Widget child,
    this.settings,
  }) : super(child: child);

  @override
  bool updateShouldNotifyDependent(
    SettingsModel oldWidget,
    Set<Aspect> dependencies,
  ) {
    final oldSettings = oldWidget.settings;
    if (dependencies.contains(Aspect.lock)) {
      if (oldSettings.uiLock != settings.uiLock) {
        return true;
      }
    }
    if (dependencies.contains(Aspect.mode)) {
      if (oldSettings.modes != settings.modes) {
        return true;
      }
    }
    if (dependencies.contains(Aspect.storage)) {
      if (oldSettings.useAES != settings.useAES ||
          oldSettings.useB64 != settings.useB64 ||
          oldSettings.storages != settings.storages) {
        return true;
      }
    }
    if (dependencies.contains(Aspect.count)) {
      if (oldSettings.blocCount != settings.blocCount ||
          oldSettings.blocCountRange != settings.blocCountRange ||
          oldSettings.blocCountDivs != settings.blocCountDivs) {
        return true;
      }
    }
    if (dependencies.contains(Aspect.size)) {
      if (oldSettings.stateSize != settings.stateSize ||
          oldSettings.stateSizeRange != settings.stateSizeRange ||
          oldSettings.stateSizeDivs != settings.stateSizeDivs) {
        return true;
      }
    }
    return false;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static SettingsModel of(BuildContext context, Aspect aspect) {
    return InheritedModel.inheritFrom<SettingsModel>(
      context,
      aspect: aspect,
    );
  }
}
