import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

enum Mode { wake, read, write, delete }
enum Storage { single, multi, ether }
enum Aspect { lock, mode, count, storage, size }

@freezed
abstract class BenchmarkSettings implements _$BenchmarkSettings {
  const BenchmarkSettings._();
  const factory BenchmarkSettings({
    @Default(true)
        bool uiLock,
    @Default(false)
        bool useAES,
    @Default(false)
        bool useB64,
    @Default(<Mode, bool>{
      Mode.wake: true,
      Mode.read: true,
      Mode.write: true,
      Mode.delete: false,
    }) // what to benchmark
        Map<Mode, bool> modes,
    @Default(<Storage, bool>{
      Storage.single: true,
      Storage.multi: true,
      Storage.ether: true,
    }) //where to benchmark
        Map<Storage, bool> storages,
    @Default(RangeValues(adjust(5), adjust(35)))
        RangeValues blocCount,
  }) = _BenchmarkSettings;

  BenchmarkSettings flipUseAES() => copyWith(useAES: !useAES);
  BenchmarkSettings flipUseB64() => copyWith(useB64: !useB64);

  BenchmarkSettings flipMode(Mode mode) =>
      copyWith(modes: {...modes, mode: !modes[mode]});

  BenchmarkSettings flipStorage(Storage storage) =>
      copyWith(storages: {...storages, storage: !storages[storage]});

  final blocCountRange = RangeValues(1, 50);
  final blocCountDivs = 10;
  // get coef => (blocCountRange.end - blocCountRange.start) / blocCountDivs;
  static double adjust(double n) => 1 + n * 49 / 50;
  // var blocCount = RangeValues(5.9, 35.3); // just amt (0-50)
  // final blocCount = RangeValues(adjust(5), adjust(35)); // just amt (0-50)
  RangeLabels get blocCountLabels => RangeLabels(
        '${blocCount.start.toInt()}',
        '${blocCount.end.toInt()}',
      );

  // // int64 size is 4 bytes
  // // string char 2 or 4 bytes
  // final stateSizeRange = RangeValues(2, 22);
  // final stateSizeDivs = 10;
  // final stateSize = RangeValues(2, 8); // 2^n size (0-20)
  // RangeLabels get stateSizeLabels => RangeLabels(
  //       _format(stateSize.start.toInt()),
  //       _format(stateSize.end.toInt()),
  //     );
  // int get stateSizeBytesMax => _convert(stateSize.end);
  // int _convert(double e) => pow(2, e).toInt();
  // String _format(int size) {
  //   final e = size % 10;
  //   final p = const ['Bytes', 'KB', 'MB', 'GB'][size ~/ 10];
  //   return '${pow(2, e)} $p';
  // }
}

@freezed
abstract class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.flipUseAES() = _FlipUseAES;
  const factory SettingsEvent.flipUseB64() = _FlipUseB64;
  const factory SettingsEvent.flipMode(Mode mode) = _FlipMode;
  const factory SettingsEvent.flipStorage(Storage storage) = _FlipStorage;
  const factory SettingsEvent.newBlocCount(RangeValues count) = _NewBlocCount;
  const factory SettingsEvent.newStateSize(RangeValues size) = _NewStateSize;
}

class SettingsBloc extends HydratedBloc<SettingsEvent, BenchmarkSettings> {
  @override
  BenchmarkSettings get initialState =>
      super.initialState ?? BenchmarkSettings();

  @override
  Stream<BenchmarkSettings> mapEventToState(SettingsEvent event) async* {
    yield event.when(
      flipUseAES: () => state.flipUseAES(),
      flipUseB64: () => state.flipUseB64(),
      flipMode: (mode) => state.flipMode(mode),
      flipStorage: (storage) => state.flipStorage(storage),
      newBlocCount: (count) => state.blocCount = count,
      newStateSize: (size) => state.stateSize = size,
    );
  }

  @override
  Map<String, dynamic> toJson(BenchmarkSettings settings) {
    return {
      'uiLock': settings.uiLock,
      'useAES': settings.useAES,
      'useB64': settings.useB64,
      'modes': settings.modes,
      'storages': settings.storages,
      'blocCount': {
        'start': settings.blocCount.start,
        'end': settings.blocCount.end
      },
      'stateSize': {
        'start': settings.stateSize.start,
        'end': settings.stateSize.end
      },
    };
  }

  @override
  BenchmarkSettings fromJson(Map<String, dynamic> json) {
    final settings = BenchmarkSettings()
      ..uiLock = json['uiLock']
      ..useAES = json['useAES']
      ..useB64 = json['useB64']
      ..modes = json['modes']
      ..storages = json['storages']
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
