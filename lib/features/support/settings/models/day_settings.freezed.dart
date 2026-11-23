// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DaySettings {

 int get dayEndHour; int get atRiskWindowHours; List<String> get habitOrder; bool get weekStartMonday; bool get hasOnboarded; bool get didCheckInOnce; bool get sinkCompletedHabits; bool get rolloverTasks; bool get streakSounds; bool get reminders; bool get morningReminderEnabled; String get morningReminderTime; bool get nightReminderEnabled; String get nightReminderTime; String get progressRange; int get schemaVersion; DateTime? get updatedAt;
/// Create a copy of DaySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaySettingsCopyWith<DaySettings> get copyWith => _$DaySettingsCopyWithImpl<DaySettings>(this as DaySettings, _$identity);

  /// Serializes this DaySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DaySettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaySettings&&(identical(other.dayEndHour, _this.dayEndHour) || other.dayEndHour == _this.dayEndHour)&&(identical(other.atRiskWindowHours, _this.atRiskWindowHours) || other.atRiskWindowHours == _this.atRiskWindowHours)&&const DeepCollectionEquality().equals(other.habitOrder, _this.habitOrder)&&(identical(other.weekStartMonday, _this.weekStartMonday) || other.weekStartMonday == _this.weekStartMonday)&&(identical(other.hasOnboarded, _this.hasOnboarded) || other.hasOnboarded == _this.hasOnboarded)&&(identical(other.didCheckInOnce, _this.didCheckInOnce) || other.didCheckInOnce == _this.didCheckInOnce)&&(identical(other.sinkCompletedHabits, _this.sinkCompletedHabits) || other.sinkCompletedHabits == _this.sinkCompletedHabits)&&(identical(other.rolloverTasks, _this.rolloverTasks) || other.rolloverTasks == _this.rolloverTasks)&&(identical(other.streakSounds, _this.streakSounds) || other.streakSounds == _this.streakSounds)&&(identical(other.reminders, _this.reminders) || other.reminders == _this.reminders)&&(identical(other.morningReminderEnabled, _this.morningReminderEnabled) || other.morningReminderEnabled == _this.morningReminderEnabled)&&(identical(other.morningReminderTime, _this.morningReminderTime) || other.morningReminderTime == _this.morningReminderTime)&&(identical(other.nightReminderEnabled, _this.nightReminderEnabled) || other.nightReminderEnabled == _this.nightReminderEnabled)&&(identical(other.nightReminderTime, _this.nightReminderTime) || other.nightReminderTime == _this.nightReminderTime)&&(identical(other.progressRange, _this.progressRange) || other.progressRange == _this.progressRange)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DaySettings;
  return Object.hash(runtimeType,_this.dayEndHour,_this.atRiskWindowHours,const DeepCollectionEquality().hash(_this.habitOrder),_this.weekStartMonday,_this.hasOnboarded,_this.didCheckInOnce,_this.sinkCompletedHabits,_this.rolloverTasks,_this.streakSounds,_this.reminders,_this.morningReminderEnabled,_this.morningReminderTime,_this.nightReminderEnabled,_this.nightReminderTime,_this.progressRange,_this.schemaVersion,_this.updatedAt);
}

@override
String toString() {
  final _this = this as DaySettings;
  return 'DaySettings(dayEndHour: ${_this.dayEndHour}, atRiskWindowHours: ${_this.atRiskWindowHours}, habitOrder: ${_this.habitOrder}, weekStartMonday: ${_this.weekStartMonday}, hasOnboarded: ${_this.hasOnboarded}, didCheckInOnce: ${_this.didCheckInOnce}, sinkCompletedHabits: ${_this.sinkCompletedHabits}, rolloverTasks: ${_this.rolloverTasks}, streakSounds: ${_this.streakSounds}, reminders: ${_this.reminders}, morningReminderEnabled: ${_this.morningReminderEnabled}, morningReminderTime: ${_this.morningReminderTime}, nightReminderEnabled: ${_this.nightReminderEnabled}, nightReminderTime: ${_this.nightReminderTime}, progressRange: ${_this.progressRange}, schemaVersion: ${_this.schemaVersion}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $DaySettingsCopyWith<$Res>  {
  factory $DaySettingsCopyWith(DaySettings value, $Res Function(DaySettings) _then) = _$DaySettingsCopyWithImpl;
@useResult
$Res call({
 int dayEndHour, int atRiskWindowHours, List<String> habitOrder, bool weekStartMonday, bool hasOnboarded, bool didCheckInOnce, bool sinkCompletedHabits, bool rolloverTasks, bool streakSounds, bool reminders, bool morningReminderEnabled, String morningReminderTime, bool nightReminderEnabled, String nightReminderTime, String progressRange, int schemaVersion, DateTime? updatedAt
});




}
/// @nodoc
class _$DaySettingsCopyWithImpl<$Res>
    implements $DaySettingsCopyWith<$Res> {
  _$DaySettingsCopyWithImpl(this._self, this._then);

  final DaySettings _self;
  final $Res Function(DaySettings) _then;

/// Create a copy of DaySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayEndHour = null,Object? atRiskWindowHours = null,Object? habitOrder = null,Object? weekStartMonday = null,Object? hasOnboarded = null,Object? didCheckInOnce = null,Object? sinkCompletedHabits = null,Object? rolloverTasks = null,Object? streakSounds = null,Object? reminders = null,Object? morningReminderEnabled = null,Object? morningReminderTime = null,Object? nightReminderEnabled = null,Object? nightReminderTime = null,Object? progressRange = null,Object? schemaVersion = null,Object? updatedAt = freezed,}) {
  return _then(DaySettings(
dayEndHour: null == dayEndHour ? _self.dayEndHour : dayEndHour // ignore: cast_nullable_to_non_nullable
as int,atRiskWindowHours: null == atRiskWindowHours ? _self.atRiskWindowHours : atRiskWindowHours // ignore: cast_nullable_to_non_nullable
as int,habitOrder: null == habitOrder ? _self.habitOrder : habitOrder // ignore: cast_nullable_to_non_nullable
as List<String>,weekStartMonday: null == weekStartMonday ? _self.weekStartMonday : weekStartMonday // ignore: cast_nullable_to_non_nullable
as bool,hasOnboarded: null == hasOnboarded ? _self.hasOnboarded : hasOnboarded // ignore: cast_nullable_to_non_nullable
as bool,didCheckInOnce: null == didCheckInOnce ? _self.didCheckInOnce : didCheckInOnce // ignore: cast_nullable_to_non_nullable
as bool,sinkCompletedHabits: null == sinkCompletedHabits ? _self.sinkCompletedHabits : sinkCompletedHabits // ignore: cast_nullable_to_non_nullable
as bool,rolloverTasks: null == rolloverTasks ? _self.rolloverTasks : rolloverTasks // ignore: cast_nullable_to_non_nullable
as bool,streakSounds: null == streakSounds ? _self.streakSounds : streakSounds // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as bool,morningReminderEnabled: null == morningReminderEnabled ? _self.morningReminderEnabled : morningReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,morningReminderTime: null == morningReminderTime ? _self.morningReminderTime : morningReminderTime // ignore: cast_nullable_to_non_nullable
as String,nightReminderEnabled: null == nightReminderEnabled ? _self.nightReminderEnabled : nightReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,nightReminderTime: null == nightReminderTime ? _self.nightReminderTime : nightReminderTime // ignore: cast_nullable_to_non_nullable
as String,progressRange: null == progressRange ? _self.progressRange : progressRange // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DaySettings].
extension DaySettingsPatterns on DaySettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaySettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaySettings value)  $default,){
final _that = this;
switch (_that) {
case _DaySettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaySettings value)?  $default,){
final _that = this;
switch (_that) {
case _DaySettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayEndHour,  int atRiskWindowHours,  List<String> habitOrder,  bool weekStartMonday,  bool hasOnboarded,  bool didCheckInOnce,  bool sinkCompletedHabits,  bool rolloverTasks,  bool streakSounds,  bool reminders,  bool morningReminderEnabled,  String morningReminderTime,  bool nightReminderEnabled,  String nightReminderTime,  String progressRange,  int schemaVersion,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaySettings() when $default != null:
return $default(_that.dayEndHour,_that.atRiskWindowHours,_that.habitOrder,_that.weekStartMonday,_that.hasOnboarded,_that.didCheckInOnce,_that.sinkCompletedHabits,_that.rolloverTasks,_that.streakSounds,_that.reminders,_that.morningReminderEnabled,_that.morningReminderTime,_that.nightReminderEnabled,_that.nightReminderTime,_that.progressRange,_that.schemaVersion,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayEndHour,  int atRiskWindowHours,  List<String> habitOrder,  bool weekStartMonday,  bool hasOnboarded,  bool didCheckInOnce,  bool sinkCompletedHabits,  bool rolloverTasks,  bool streakSounds,  bool reminders,  bool morningReminderEnabled,  String morningReminderTime,  bool nightReminderEnabled,  String nightReminderTime,  String progressRange,  int schemaVersion,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DaySettings():
return $default(_that.dayEndHour,_that.atRiskWindowHours,_that.habitOrder,_that.weekStartMonday,_that.hasOnboarded,_that.didCheckInOnce,_that.sinkCompletedHabits,_that.rolloverTasks,_that.streakSounds,_that.reminders,_that.morningReminderEnabled,_that.morningReminderTime,_that.nightReminderEnabled,_that.nightReminderTime,_that.progressRange,_that.schemaVersion,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayEndHour,  int atRiskWindowHours,  List<String> habitOrder,  bool weekStartMonday,  bool hasOnboarded,  bool didCheckInOnce,  bool sinkCompletedHabits,  bool rolloverTasks,  bool streakSounds,  bool reminders,  bool morningReminderEnabled,  String morningReminderTime,  bool nightReminderEnabled,  String nightReminderTime,  String progressRange,  int schemaVersion,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DaySettings() when $default != null:
return $default(_that.dayEndHour,_that.atRiskWindowHours,_that.habitOrder,_that.weekStartMonday,_that.hasOnboarded,_that.didCheckInOnce,_that.sinkCompletedHabits,_that.rolloverTasks,_that.streakSounds,_that.reminders,_that.morningReminderEnabled,_that.morningReminderTime,_that.nightReminderEnabled,_that.nightReminderTime,_that.progressRange,_that.schemaVersion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaySettings extends DaySettings {
  const _DaySettings({this.dayEndHour = 3, this.atRiskWindowHours = 4,  List<String> habitOrder = const <String>[], this.weekStartMonday = false, this.hasOnboarded = false, this.didCheckInOnce = false, this.sinkCompletedHabits = true, this.rolloverTasks = false, this.streakSounds = true, this.reminders = false, this.morningReminderEnabled = false, this.morningReminderTime = '09:00', this.nightReminderEnabled = false, this.nightReminderTime = '21:00', this.progressRange = '1m', this.schemaVersion = 1, this.updatedAt}): _habitOrder = habitOrder,super._();
  factory _DaySettings.fromJson(Map<String, dynamic> json) => _$DaySettingsFromJson(json);

@override@JsonKey() final  int dayEndHour;
@override@JsonKey() final  int atRiskWindowHours;
 final  List<String> _habitOrder;
@override@JsonKey() List<String> get habitOrder {
  if (_habitOrder is EqualUnmodifiableListView) return _habitOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_habitOrder);
}

@override@JsonKey() final  bool weekStartMonday;
@override@JsonKey() final  bool hasOnboarded;
@override@JsonKey() final  bool didCheckInOnce;
@override@JsonKey() final  bool sinkCompletedHabits;
@override@JsonKey() final  bool rolloverTasks;
@override@JsonKey() final  bool streakSounds;
@override@JsonKey() final  bool reminders;
@override@JsonKey() final  bool morningReminderEnabled;
@override@JsonKey() final  String morningReminderTime;
@override@JsonKey() final  bool nightReminderEnabled;
@override@JsonKey() final  String nightReminderTime;
@override@JsonKey() final  String progressRange;
@override@JsonKey() final  int schemaVersion;
@override final  DateTime? updatedAt;

/// Create a copy of DaySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaySettingsCopyWith<_DaySettings> get copyWith => __$DaySettingsCopyWithImpl<_DaySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaySettings&&(identical(other.dayEndHour, dayEndHour) || other.dayEndHour == dayEndHour)&&(identical(other.atRiskWindowHours, atRiskWindowHours) || other.atRiskWindowHours == atRiskWindowHours)&&const DeepCollectionEquality().equals(other.habitOrder, _habitOrder)&&(identical(other.weekStartMonday, weekStartMonday) || other.weekStartMonday == weekStartMonday)&&(identical(other.hasOnboarded, hasOnboarded) || other.hasOnboarded == hasOnboarded)&&(identical(other.didCheckInOnce, didCheckInOnce) || other.didCheckInOnce == didCheckInOnce)&&(identical(other.sinkCompletedHabits, sinkCompletedHabits) || other.sinkCompletedHabits == sinkCompletedHabits)&&(identical(other.rolloverTasks, rolloverTasks) || other.rolloverTasks == rolloverTasks)&&(identical(other.streakSounds, streakSounds) || other.streakSounds == streakSounds)&&(identical(other.reminders, reminders) || other.reminders == reminders)&&(identical(other.morningReminderEnabled, morningReminderEnabled) || other.morningReminderEnabled == morningReminderEnabled)&&(identical(other.morningReminderTime, morningReminderTime) || other.morningReminderTime == morningReminderTime)&&(identical(other.nightReminderEnabled, nightReminderEnabled) || other.nightReminderEnabled == nightReminderEnabled)&&(identical(other.nightReminderTime, nightReminderTime) || other.nightReminderTime == nightReminderTime)&&(identical(other.progressRange, progressRange) || other.progressRange == progressRange)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dayEndHour,atRiskWindowHours,const DeepCollectionEquality().hash(_habitOrder),weekStartMonday,hasOnboarded,didCheckInOnce,sinkCompletedHabits,rolloverTasks,streakSounds,reminders,morningReminderEnabled,morningReminderTime,nightReminderEnabled,nightReminderTime,progressRange,schemaVersion,updatedAt);
}

@override
String toString() {
    return 'DaySettings(dayEndHour: $dayEndHour, atRiskWindowHours: $atRiskWindowHours, habitOrder: $habitOrder, weekStartMonday: $weekStartMonday, hasOnboarded: $hasOnboarded, didCheckInOnce: $didCheckInOnce, sinkCompletedHabits: $sinkCompletedHabits, rolloverTasks: $rolloverTasks, streakSounds: $streakSounds, reminders: $reminders, morningReminderEnabled: $morningReminderEnabled, morningReminderTime: $morningReminderTime, nightReminderEnabled: $nightReminderEnabled, nightReminderTime: $nightReminderTime, progressRange: $progressRange, schemaVersion: $schemaVersion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DaySettingsCopyWith<$Res> implements $DaySettingsCopyWith<$Res> {
  factory _$DaySettingsCopyWith(_DaySettings value, $Res Function(_DaySettings) _then) = __$DaySettingsCopyWithImpl;
@override @useResult
$Res call({
 int dayEndHour, int atRiskWindowHours, List<String> habitOrder, bool weekStartMonday, bool hasOnboarded, bool didCheckInOnce, bool sinkCompletedHabits, bool rolloverTasks, bool streakSounds, bool reminders, bool morningReminderEnabled, String morningReminderTime, bool nightReminderEnabled, String nightReminderTime, String progressRange, int schemaVersion, DateTime? updatedAt
});




}
/// @nodoc
class __$DaySettingsCopyWithImpl<$Res>
    implements _$DaySettingsCopyWith<$Res> {
  __$DaySettingsCopyWithImpl(this._self, this._then);

  final _DaySettings _self;
  final $Res Function(_DaySettings) _then;

/// Create a copy of DaySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayEndHour = null,Object? atRiskWindowHours = null,Object? habitOrder = null,Object? weekStartMonday = null,Object? hasOnboarded = null,Object? didCheckInOnce = null,Object? sinkCompletedHabits = null,Object? rolloverTasks = null,Object? streakSounds = null,Object? reminders = null,Object? morningReminderEnabled = null,Object? morningReminderTime = null,Object? nightReminderEnabled = null,Object? nightReminderTime = null,Object? progressRange = null,Object? schemaVersion = null,Object? updatedAt = freezed,}) {
  return _then(_DaySettings(
dayEndHour: null == dayEndHour ? _self.dayEndHour : dayEndHour // ignore: cast_nullable_to_non_nullable
as int,atRiskWindowHours: null == atRiskWindowHours ? _self.atRiskWindowHours : atRiskWindowHours // ignore: cast_nullable_to_non_nullable
as int,habitOrder: null == habitOrder ? _self._habitOrder : habitOrder // ignore: cast_nullable_to_non_nullable
as List<String>,weekStartMonday: null == weekStartMonday ? _self.weekStartMonday : weekStartMonday // ignore: cast_nullable_to_non_nullable
as bool,hasOnboarded: null == hasOnboarded ? _self.hasOnboarded : hasOnboarded // ignore: cast_nullable_to_non_nullable
as bool,didCheckInOnce: null == didCheckInOnce ? _self.didCheckInOnce : didCheckInOnce // ignore: cast_nullable_to_non_nullable
as bool,sinkCompletedHabits: null == sinkCompletedHabits ? _self.sinkCompletedHabits : sinkCompletedHabits // ignore: cast_nullable_to_non_nullable
as bool,rolloverTasks: null == rolloverTasks ? _self.rolloverTasks : rolloverTasks // ignore: cast_nullable_to_non_nullable
as bool,streakSounds: null == streakSounds ? _self.streakSounds : streakSounds // ignore: cast_nullable_to_non_nullable
as bool,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as bool,morningReminderEnabled: null == morningReminderEnabled ? _self.morningReminderEnabled : morningReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,morningReminderTime: null == morningReminderTime ? _self.morningReminderTime : morningReminderTime // ignore: cast_nullable_to_non_nullable
as String,nightReminderEnabled: null == nightReminderEnabled ? _self.nightReminderEnabled : nightReminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,nightReminderTime: null == nightReminderTime ? _self.nightReminderTime : nightReminderTime // ignore: cast_nullable_to_non_nullable
as String,progressRange: null == progressRange ? _self.progressRange : progressRange // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
