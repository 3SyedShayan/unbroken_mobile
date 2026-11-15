// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakStats {

 int get current; int get best; DateTime? get lastCompletedDay;
/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakStatsCopyWith<StreakStats> get copyWith => _$StreakStatsCopyWithImpl<StreakStats>(this as StreakStats, _$identity);

  /// Serializes this StreakStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StreakStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakStats&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.best, _this.best) || other.best == _this.best)&&(identical(other.lastCompletedDay, _this.lastCompletedDay) || other.lastCompletedDay == _this.lastCompletedDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StreakStats;
  return Object.hash(runtimeType,_this.current,_this.best,_this.lastCompletedDay);
}

@override
String toString() {
  final _this = this as StreakStats;
  return 'StreakStats(current: ${_this.current}, best: ${_this.best}, lastCompletedDay: ${_this.lastCompletedDay})';
}


}

/// @nodoc
abstract mixin class $StreakStatsCopyWith<$Res>  {
  factory $StreakStatsCopyWith(StreakStats value, $Res Function(StreakStats) _then) = _$StreakStatsCopyWithImpl;
@useResult
$Res call({
 int current, int best, DateTime? lastCompletedDay
});




}
/// @nodoc
class _$StreakStatsCopyWithImpl<$Res>
    implements $StreakStatsCopyWith<$Res> {
  _$StreakStatsCopyWithImpl(this._self, this._then);

  final StreakStats _self;
  final $Res Function(StreakStats) _then;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? best = null,Object? lastCompletedDay = freezed,}) {
  return _then(StreakStats(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDay: freezed == lastCompletedDay ? _self.lastCompletedDay : lastCompletedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakStats].
extension StreakStatsPatterns on StreakStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakStats value)  $default,){
final _that = this;
switch (_that) {
case _StreakStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakStats value)?  $default,){
final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int best,  DateTime? lastCompletedDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
return $default(_that.current,_that.best,_that.lastCompletedDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int best,  DateTime? lastCompletedDay)  $default,) {final _that = this;
switch (_that) {
case _StreakStats():
return $default(_that.current,_that.best,_that.lastCompletedDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int best,  DateTime? lastCompletedDay)?  $default,) {final _that = this;
switch (_that) {
case _StreakStats() when $default != null:
return $default(_that.current,_that.best,_that.lastCompletedDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakStats implements StreakStats {
  const _StreakStats({this.current = 0, this.best = 0, this.lastCompletedDay});
  factory _StreakStats.fromJson(Map<String, dynamic> json) => _$StreakStatsFromJson(json);

@override@JsonKey() final  int current;
@override@JsonKey() final  int best;
@override final  DateTime? lastCompletedDay;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakStatsCopyWith<_StreakStats> get copyWith => __$StreakStatsCopyWithImpl<_StreakStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakStats&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best)&&(identical(other.lastCompletedDay, lastCompletedDay) || other.lastCompletedDay == lastCompletedDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,current,best,lastCompletedDay);
}

@override
String toString() {
    return 'StreakStats(current: $current, best: $best, lastCompletedDay: $lastCompletedDay)';
}


}

/// @nodoc
abstract mixin class _$StreakStatsCopyWith<$Res> implements $StreakStatsCopyWith<$Res> {
  factory _$StreakStatsCopyWith(_StreakStats value, $Res Function(_StreakStats) _then) = __$StreakStatsCopyWithImpl;
@override @useResult
$Res call({
 int current, int best, DateTime? lastCompletedDay
});




}
/// @nodoc
class __$StreakStatsCopyWithImpl<$Res>
    implements _$StreakStatsCopyWith<$Res> {
  __$StreakStatsCopyWithImpl(this._self, this._then);

  final _StreakStats _self;
  final $Res Function(_StreakStats) _then;

/// Create a copy of StreakStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? best = null,Object? lastCompletedDay = freezed,}) {
  return _then(_StreakStats(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDay: freezed == lastCompletedDay ? _self.lastCompletedDay : lastCompletedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
