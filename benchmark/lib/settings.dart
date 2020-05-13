import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

enum Mode { wake, read, write, delete }
enum Storage { single, multi, hive }

class BenchmarkSettings with EquatableMixin {
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
    Storage.hive: true,
  }; //where to benchmark
  void addStorage(Storage storage) => storages[storage] = true;
  void delStorage(Storage storage) => storages[storage] = false;
  void flipStorage(Storage storage) => storages[storage] = !storages[storage];

  final blocCountRange = RangeValues(1, 150);
  final blocCountDivs = 10;
  // get coef => (blocCountRange.end - blocCountRange.start) / blocCountDivs;
  static double adjust(double n) => 1 + n * 149 / 150;
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

  @override
  List<Object> get props =>
      [uiLock, useAES, useB64, modes, storages, blocCount, stateSize];

  BenchmarkSettings get copy => BenchmarkSettings()
    ..uiLock = uiLock
    ..useAES = useAES
    ..useB64 = useB64
    ..modes = {...modes}
    ..storages = {...storages}
    ..blocCount = blocCount
    ..stateSize = stateSize;
}

@freezed
abstract class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.setUiLock(bool uiLock) = _UiLock;
  const factory SettingsEvent.flipUseAES() = _FlipUseAES;
  const factory SettingsEvent.flipUseB64() = _FlipUseB64;
  const factory SettingsEvent.flipMode(Mode mode) = _FlipMode;
  const factory SettingsEvent.flipStorage(Storage storage) = _FlipStorage;
  const factory SettingsEvent.setBlocCount(RangeValues count) = _NewBlocCount;
  const factory SettingsEvent.setStateSize(RangeValues size) = _NewStateSize;
}

class SettingsBloc extends HydratedBloc<SettingsEvent, BenchmarkSettings> {
  @override
  BenchmarkSettings get initialState =>
      super.initialState ?? BenchmarkSettings();

  @override
  Stream<BenchmarkSettings> mapEventToState(SettingsEvent event) async* {
    final copy = state.copy;
    event.when(
      setUiLock: (uiLock) => copy.uiLock = uiLock,
      flipUseAES: () => copy.flipUseAES(),
      flipUseB64: () => copy.flipUseB64(),
      flipMode: (mode) => copy.flipMode(mode),
      flipStorage: (storage) => copy.flipStorage(storage),
      setBlocCount: (count) => copy.blocCount = count,
      setStateSize: (size) => copy.stateSize = size,
    );
    yield copy;
  }

  @override
  Map<String, dynamic> toJson(BenchmarkSettings settings) {
    final json = {
      'uiLock': settings.uiLock,
      'useAES': settings.useAES,
      'useB64': settings.useB64,
      'modes': settings.modes.map((k, v) => MapEntry('${k.index}', v)),
      'storages': settings.storages.map((k, v) => MapEntry('${k.index}', v)),
      'blocCount': {
        'start': settings.blocCount.start,
        'end': settings.blocCount.end
      },
      'stateSize': {
        'start': settings.stateSize.start,
        'end': settings.stateSize.end
      },
    };

    return json;
  }

  @override
  BenchmarkSettings fromJson(Map<String, dynamic> json) {
    final settings = BenchmarkSettings()
      ..uiLock = json['uiLock']
      ..useAES = json['useAES']
      ..useB64 = json['useB64']
      ..modes = (json['modes'] as Map)
          .cast<String, bool>()
          .map((k, v) => MapEntry(Mode.values[int.parse(k)], v))
      ..storages = (json['storages'] as Map)
          .cast<String, bool>()
          .map((k, v) => MapEntry(Storage.values[int.parse(k)], v))
      ..blocCount = RangeValues(
        json['blocCount']['start'],
        json['blocCount']['end'],
      )
      ..stateSize = RangeValues(
        json['stateSize']['start'],
        json['stateSize']['end'],
      );

    return settings;
  }
}
