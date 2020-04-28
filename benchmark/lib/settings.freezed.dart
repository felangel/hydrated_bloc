// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SettingsEventTearOff {
  const _$SettingsEventTearOff();

  _UiLock setUiLock(bool uiLock) {
    return _UiLock(
      uiLock,
    );
  }

  _FlipUseAES flipUseAES() {
    return const _FlipUseAES();
  }

  _FlipUseB64 flipUseB64() {
    return const _FlipUseB64();
  }

  _FlipMode flipMode(Mode mode) {
    return _FlipMode(
      mode,
    );
  }

  _FlipStorage flipStorage(Storage storage) {
    return _FlipStorage(
      storage,
    );
  }

  _NewBlocCount setBlocCount(RangeValues count) {
    return _NewBlocCount(
      count,
    );
  }

  _NewStateSize setStateSize(RangeValues size) {
    return _NewStateSize(
      size,
    );
  }
}

// ignore: unused_element
const $SettingsEvent = _$SettingsEventTearOff();

mixin _$SettingsEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  });
}

abstract class $SettingsEventCopyWith<$Res> {
  factory $SettingsEventCopyWith(
          SettingsEvent value, $Res Function(SettingsEvent) then) =
      _$SettingsEventCopyWithImpl<$Res>;
}

class _$SettingsEventCopyWithImpl<$Res>
    implements $SettingsEventCopyWith<$Res> {
  _$SettingsEventCopyWithImpl(this._value, this._then);

  final SettingsEvent _value;
  // ignore: unused_field
  final $Res Function(SettingsEvent) _then;
}

abstract class _$UiLockCopyWith<$Res> {
  factory _$UiLockCopyWith(_UiLock value, $Res Function(_UiLock) then) =
      __$UiLockCopyWithImpl<$Res>;
  $Res call({bool uiLock});
}

class __$UiLockCopyWithImpl<$Res> extends _$SettingsEventCopyWithImpl<$Res>
    implements _$UiLockCopyWith<$Res> {
  __$UiLockCopyWithImpl(_UiLock _value, $Res Function(_UiLock) _then)
      : super(_value, (v) => _then(v as _UiLock));

  @override
  _UiLock get _value => super._value as _UiLock;

  @override
  $Res call({
    Object uiLock = freezed,
  }) {
    return _then(_UiLock(
      uiLock == freezed ? _value.uiLock : uiLock as bool,
    ));
  }
}

class _$_UiLock with DiagnosticableTreeMixin implements _UiLock {
  const _$_UiLock(this.uiLock) : assert(uiLock != null);

  @override
  final bool uiLock;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.setUiLock(uiLock: $uiLock)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsEvent.setUiLock'))
      ..add(DiagnosticsProperty('uiLock', uiLock));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UiLock &&
            (identical(other.uiLock, uiLock) ||
                const DeepCollectionEquality().equals(other.uiLock, uiLock)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(uiLock);

  @override
  _$UiLockCopyWith<_UiLock> get copyWith =>
      __$UiLockCopyWithImpl<_UiLock>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setUiLock(uiLock);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setUiLock != null) {
      return setUiLock(uiLock);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setUiLock(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setUiLock != null) {
      return setUiLock(this);
    }
    return orElse();
  }
}

abstract class _UiLock implements SettingsEvent {
  const factory _UiLock(bool uiLock) = _$_UiLock;

  bool get uiLock;
  _$UiLockCopyWith<_UiLock> get copyWith;
}

abstract class _$FlipUseAESCopyWith<$Res> {
  factory _$FlipUseAESCopyWith(
          _FlipUseAES value, $Res Function(_FlipUseAES) then) =
      __$FlipUseAESCopyWithImpl<$Res>;
}

class __$FlipUseAESCopyWithImpl<$Res> extends _$SettingsEventCopyWithImpl<$Res>
    implements _$FlipUseAESCopyWith<$Res> {
  __$FlipUseAESCopyWithImpl(
      _FlipUseAES _value, $Res Function(_FlipUseAES) _then)
      : super(_value, (v) => _then(v as _FlipUseAES));

  @override
  _FlipUseAES get _value => super._value as _FlipUseAES;
}

class _$_FlipUseAES with DiagnosticableTreeMixin implements _FlipUseAES {
  const _$_FlipUseAES();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.flipUseAES()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'SettingsEvent.flipUseAES'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _FlipUseAES);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipUseAES();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipUseAES != null) {
      return flipUseAES();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipUseAES(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipUseAES != null) {
      return flipUseAES(this);
    }
    return orElse();
  }
}

abstract class _FlipUseAES implements SettingsEvent {
  const factory _FlipUseAES() = _$_FlipUseAES;
}

abstract class _$FlipUseB64CopyWith<$Res> {
  factory _$FlipUseB64CopyWith(
          _FlipUseB64 value, $Res Function(_FlipUseB64) then) =
      __$FlipUseB64CopyWithImpl<$Res>;
}

class __$FlipUseB64CopyWithImpl<$Res> extends _$SettingsEventCopyWithImpl<$Res>
    implements _$FlipUseB64CopyWith<$Res> {
  __$FlipUseB64CopyWithImpl(
      _FlipUseB64 _value, $Res Function(_FlipUseB64) _then)
      : super(_value, (v) => _then(v as _FlipUseB64));

  @override
  _FlipUseB64 get _value => super._value as _FlipUseB64;
}

class _$_FlipUseB64 with DiagnosticableTreeMixin implements _FlipUseB64 {
  const _$_FlipUseB64();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.flipUseB64()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'SettingsEvent.flipUseB64'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _FlipUseB64);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipUseB64();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipUseB64 != null) {
      return flipUseB64();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipUseB64(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipUseB64 != null) {
      return flipUseB64(this);
    }
    return orElse();
  }
}

abstract class _FlipUseB64 implements SettingsEvent {
  const factory _FlipUseB64() = _$_FlipUseB64;
}

abstract class _$FlipModeCopyWith<$Res> {
  factory _$FlipModeCopyWith(_FlipMode value, $Res Function(_FlipMode) then) =
      __$FlipModeCopyWithImpl<$Res>;
  $Res call({Mode mode});
}

class __$FlipModeCopyWithImpl<$Res> extends _$SettingsEventCopyWithImpl<$Res>
    implements _$FlipModeCopyWith<$Res> {
  __$FlipModeCopyWithImpl(_FlipMode _value, $Res Function(_FlipMode) _then)
      : super(_value, (v) => _then(v as _FlipMode));

  @override
  _FlipMode get _value => super._value as _FlipMode;

  @override
  $Res call({
    Object mode = freezed,
  }) {
    return _then(_FlipMode(
      mode == freezed ? _value.mode : mode as Mode,
    ));
  }
}

class _$_FlipMode with DiagnosticableTreeMixin implements _FlipMode {
  const _$_FlipMode(this.mode) : assert(mode != null);

  @override
  final Mode mode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.flipMode(mode: $mode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsEvent.flipMode'))
      ..add(DiagnosticsProperty('mode', mode));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _FlipMode &&
            (identical(other.mode, mode) ||
                const DeepCollectionEquality().equals(other.mode, mode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(mode);

  @override
  _$FlipModeCopyWith<_FlipMode> get copyWith =>
      __$FlipModeCopyWithImpl<_FlipMode>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipMode(mode);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipMode != null) {
      return flipMode(mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipMode(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipMode != null) {
      return flipMode(this);
    }
    return orElse();
  }
}

abstract class _FlipMode implements SettingsEvent {
  const factory _FlipMode(Mode mode) = _$_FlipMode;

  Mode get mode;
  _$FlipModeCopyWith<_FlipMode> get copyWith;
}

abstract class _$FlipStorageCopyWith<$Res> {
  factory _$FlipStorageCopyWith(
          _FlipStorage value, $Res Function(_FlipStorage) then) =
      __$FlipStorageCopyWithImpl<$Res>;
  $Res call({Storage storage});
}

class __$FlipStorageCopyWithImpl<$Res> extends _$SettingsEventCopyWithImpl<$Res>
    implements _$FlipStorageCopyWith<$Res> {
  __$FlipStorageCopyWithImpl(
      _FlipStorage _value, $Res Function(_FlipStorage) _then)
      : super(_value, (v) => _then(v as _FlipStorage));

  @override
  _FlipStorage get _value => super._value as _FlipStorage;

  @override
  $Res call({
    Object storage = freezed,
  }) {
    return _then(_FlipStorage(
      storage == freezed ? _value.storage : storage as Storage,
    ));
  }
}

class _$_FlipStorage with DiagnosticableTreeMixin implements _FlipStorage {
  const _$_FlipStorage(this.storage) : assert(storage != null);

  @override
  final Storage storage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.flipStorage(storage: $storage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsEvent.flipStorage'))
      ..add(DiagnosticsProperty('storage', storage));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _FlipStorage &&
            (identical(other.storage, storage) ||
                const DeepCollectionEquality().equals(other.storage, storage)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(storage);

  @override
  _$FlipStorageCopyWith<_FlipStorage> get copyWith =>
      __$FlipStorageCopyWithImpl<_FlipStorage>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipStorage(storage);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipStorage != null) {
      return flipStorage(storage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return flipStorage(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (flipStorage != null) {
      return flipStorage(this);
    }
    return orElse();
  }
}

abstract class _FlipStorage implements SettingsEvent {
  const factory _FlipStorage(Storage storage) = _$_FlipStorage;

  Storage get storage;
  _$FlipStorageCopyWith<_FlipStorage> get copyWith;
}

abstract class _$NewBlocCountCopyWith<$Res> {
  factory _$NewBlocCountCopyWith(
          _NewBlocCount value, $Res Function(_NewBlocCount) then) =
      __$NewBlocCountCopyWithImpl<$Res>;
  $Res call({RangeValues count});
}

class __$NewBlocCountCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res>
    implements _$NewBlocCountCopyWith<$Res> {
  __$NewBlocCountCopyWithImpl(
      _NewBlocCount _value, $Res Function(_NewBlocCount) _then)
      : super(_value, (v) => _then(v as _NewBlocCount));

  @override
  _NewBlocCount get _value => super._value as _NewBlocCount;

  @override
  $Res call({
    Object count = freezed,
  }) {
    return _then(_NewBlocCount(
      count == freezed ? _value.count : count as RangeValues,
    ));
  }
}

class _$_NewBlocCount with DiagnosticableTreeMixin implements _NewBlocCount {
  const _$_NewBlocCount(this.count) : assert(count != null);

  @override
  final RangeValues count;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.setBlocCount(count: $count)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsEvent.setBlocCount'))
      ..add(DiagnosticsProperty('count', count));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NewBlocCount &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(count);

  @override
  _$NewBlocCountCopyWith<_NewBlocCount> get copyWith =>
      __$NewBlocCountCopyWithImpl<_NewBlocCount>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setBlocCount(count);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setBlocCount != null) {
      return setBlocCount(count);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setBlocCount(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setBlocCount != null) {
      return setBlocCount(this);
    }
    return orElse();
  }
}

abstract class _NewBlocCount implements SettingsEvent {
  const factory _NewBlocCount(RangeValues count) = _$_NewBlocCount;

  RangeValues get count;
  _$NewBlocCountCopyWith<_NewBlocCount> get copyWith;
}

abstract class _$NewStateSizeCopyWith<$Res> {
  factory _$NewStateSizeCopyWith(
          _NewStateSize value, $Res Function(_NewStateSize) then) =
      __$NewStateSizeCopyWithImpl<$Res>;
  $Res call({RangeValues size});
}

class __$NewStateSizeCopyWithImpl<$Res>
    extends _$SettingsEventCopyWithImpl<$Res>
    implements _$NewStateSizeCopyWith<$Res> {
  __$NewStateSizeCopyWithImpl(
      _NewStateSize _value, $Res Function(_NewStateSize) _then)
      : super(_value, (v) => _then(v as _NewStateSize));

  @override
  _NewStateSize get _value => super._value as _NewStateSize;

  @override
  $Res call({
    Object size = freezed,
  }) {
    return _then(_NewStateSize(
      size == freezed ? _value.size : size as RangeValues,
    ));
  }
}

class _$_NewStateSize with DiagnosticableTreeMixin implements _NewStateSize {
  const _$_NewStateSize(this.size) : assert(size != null);

  @override
  final RangeValues size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsEvent.setStateSize(size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsEvent.setStateSize'))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NewStateSize &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(size);

  @override
  _$NewStateSizeCopyWith<_NewStateSize> get copyWith =>
      __$NewStateSizeCopyWithImpl<_NewStateSize>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result setUiLock(bool uiLock),
    @required Result flipUseAES(),
    @required Result flipUseB64(),
    @required Result flipMode(Mode mode),
    @required Result flipStorage(Storage storage),
    @required Result setBlocCount(RangeValues count),
    @required Result setStateSize(RangeValues size),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setStateSize(size);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result setUiLock(bool uiLock),
    Result flipUseAES(),
    Result flipUseB64(),
    Result flipMode(Mode mode),
    Result flipStorage(Storage storage),
    Result setBlocCount(RangeValues count),
    Result setStateSize(RangeValues size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setStateSize != null) {
      return setStateSize(size);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result setUiLock(_UiLock value),
    @required Result flipUseAES(_FlipUseAES value),
    @required Result flipUseB64(_FlipUseB64 value),
    @required Result flipMode(_FlipMode value),
    @required Result flipStorage(_FlipStorage value),
    @required Result setBlocCount(_NewBlocCount value),
    @required Result setStateSize(_NewStateSize value),
  }) {
    assert(setUiLock != null);
    assert(flipUseAES != null);
    assert(flipUseB64 != null);
    assert(flipMode != null);
    assert(flipStorage != null);
    assert(setBlocCount != null);
    assert(setStateSize != null);
    return setStateSize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result setUiLock(_UiLock value),
    Result flipUseAES(_FlipUseAES value),
    Result flipUseB64(_FlipUseB64 value),
    Result flipMode(_FlipMode value),
    Result flipStorage(_FlipStorage value),
    Result setBlocCount(_NewBlocCount value),
    Result setStateSize(_NewStateSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setStateSize != null) {
      return setStateSize(this);
    }
    return orElse();
  }
}

abstract class _NewStateSize implements SettingsEvent {
  const factory _NewStateSize(RangeValues size) = _$_NewStateSize;

  RangeValues get size;
  _$NewStateSizeCopyWith<_NewStateSize> get copyWith;
}
