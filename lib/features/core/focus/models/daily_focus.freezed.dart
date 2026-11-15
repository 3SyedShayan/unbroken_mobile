// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_focus.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyFocus {

 String get logicalDayKey; Map<String, FocusItem> get slots; DateTime? get updatedAt;
/// Create a copy of DailyFocus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyFocusCopyWith<DailyFocus> get copyWith => _$DailyFocusCopyWithImpl<DailyFocus>(this as DailyFocus, _$identity);

  /// Serializes this DailyFocus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DailyFocus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyFocus&&(identical(other.logicalDayKey, _this.logicalDayKey) || other.logicalDayKey == _this.logicalDayKey)&&const DeepCollectionEquality().equals(other.slots, _this.slots)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DailyFocus;
  return Object.hash(runtimeType,_this.logicalDayKey,const DeepCollectionEquality().hash(_this.slots),_this.updatedAt);
}

@override
String toString() {
  final _this = this as DailyFocus;
  return 'DailyFocus(logicalDayKey: ${_this.logicalDayKey}, slots: ${_this.slots}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $DailyFocusCopyWith<$Res>  {
  factory $DailyFocusCopyWith(DailyFocus value, $Res Function(DailyFocus) _then) = _$DailyFocusCopyWithImpl;
@useResult
$Res call({
 String logicalDayKey, Map<String, FocusItem> slots, DateTime? updatedAt
});




}
/// @nodoc
class _$DailyFocusCopyWithImpl<$Res>
    implements $DailyFocusCopyWith<$Res> {
  _$DailyFocusCopyWithImpl(this._self, this._then);

  final DailyFocus _self;
  final $Res Function(DailyFocus) _then;

/// Create a copy of DailyFocus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logicalDayKey = null,Object? slots = null,Object? updatedAt = freezed,}) {
  return _then(DailyFocus(
logicalDayKey: null == logicalDayKey ? _self.logicalDayKey : logicalDayKey // ignore: cast_nullable_to_non_nullable
as String,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as Map<String, FocusItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyFocus].
extension DailyFocusPatterns on DailyFocus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyFocus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyFocus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyFocus value)  $default,){
final _that = this;
switch (_that) {
case _DailyFocus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyFocus value)?  $default,){
final _that = this;
switch (_that) {
case _DailyFocus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String logicalDayKey,  Map<String, FocusItem> slots,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyFocus() when $default != null:
return $default(_that.logicalDayKey,_that.slots,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String logicalDayKey,  Map<String, FocusItem> slots,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DailyFocus():
return $default(_that.logicalDayKey,_that.slots,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String logicalDayKey,  Map<String, FocusItem> slots,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DailyFocus() when $default != null:
return $default(_that.logicalDayKey,_that.slots,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyFocus extends DailyFocus {
  const _DailyFocus({required this.logicalDayKey,  Map<String, FocusItem> slots = const <String, FocusItem>{}, this.updatedAt}): _slots = slots,super._();
  factory _DailyFocus.fromJson(Map<String, dynamic> json) => _$DailyFocusFromJson(json);

@override final  String logicalDayKey;
 final  Map<String, FocusItem> _slots;
@override@JsonKey() Map<String, FocusItem> get slots {
  if (_slots is EqualUnmodifiableMapView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_slots);
}

@override final  DateTime? updatedAt;

/// Create a copy of DailyFocus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyFocusCopyWith<_DailyFocus> get copyWith => __$DailyFocusCopyWithImpl<_DailyFocus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyFocusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyFocus&&(identical(other.logicalDayKey, logicalDayKey) || other.logicalDayKey == logicalDayKey)&&const DeepCollectionEquality().equals(other.slots, _slots)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,logicalDayKey,const DeepCollectionEquality().hash(_slots),updatedAt);
}

@override
String toString() {
    return 'DailyFocus(logicalDayKey: $logicalDayKey, slots: $slots, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DailyFocusCopyWith<$Res> implements $DailyFocusCopyWith<$Res> {
  factory _$DailyFocusCopyWith(_DailyFocus value, $Res Function(_DailyFocus) _then) = __$DailyFocusCopyWithImpl;
@override @useResult
$Res call({
 String logicalDayKey, Map<String, FocusItem> slots, DateTime? updatedAt
});




}
/// @nodoc
class __$DailyFocusCopyWithImpl<$Res>
    implements _$DailyFocusCopyWith<$Res> {
  __$DailyFocusCopyWithImpl(this._self, this._then);

  final _DailyFocus _self;
  final $Res Function(_DailyFocus) _then;

/// Create a copy of DailyFocus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logicalDayKey = null,Object? slots = null,Object? updatedAt = freezed,}) {
  return _then(_DailyFocus(
logicalDayKey: null == logicalDayKey ? _self.logicalDayKey : logicalDayKey // ignore: cast_nullable_to_non_nullable
as String,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as Map<String, FocusItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
