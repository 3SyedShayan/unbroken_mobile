// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_task_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyTaskResult {

 String get dayKey; DateTime get day; List<FocusItem> get items;
/// Create a copy of DailyTaskResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyTaskResultCopyWith<DailyTaskResult> get copyWith => _$DailyTaskResultCopyWithImpl<DailyTaskResult>(this as DailyTaskResult, _$identity);

  /// Serializes this DailyTaskResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DailyTaskResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyTaskResult&&(identical(other.dayKey, _this.dayKey) || other.dayKey == _this.dayKey)&&(identical(other.day, _this.day) || other.day == _this.day)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DailyTaskResult;
  return Object.hash(runtimeType,_this.dayKey,_this.day,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as DailyTaskResult;
  return 'DailyTaskResult(dayKey: ${_this.dayKey}, day: ${_this.day}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $DailyTaskResultCopyWith<$Res>  {
  factory $DailyTaskResultCopyWith(DailyTaskResult value, $Res Function(DailyTaskResult) _then) = _$DailyTaskResultCopyWithImpl;
@useResult
$Res call({
 String dayKey, DateTime day, List<FocusItem> items
});




}
/// @nodoc
class _$DailyTaskResultCopyWithImpl<$Res>
    implements $DailyTaskResultCopyWith<$Res> {
  _$DailyTaskResultCopyWithImpl(this._self, this._then);

  final DailyTaskResult _self;
  final $Res Function(DailyTaskResult) _then;

/// Create a copy of DailyTaskResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayKey = null,Object? day = null,Object? items = null,}) {
  return _then(DailyTaskResult(
dayKey: null == dayKey ? _self.dayKey : dayKey // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FocusItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyTaskResult].
extension DailyTaskResultPatterns on DailyTaskResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyTaskResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyTaskResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyTaskResult value)  $default,){
final _that = this;
switch (_that) {
case _DailyTaskResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyTaskResult value)?  $default,){
final _that = this;
switch (_that) {
case _DailyTaskResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dayKey,  DateTime day,  List<FocusItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyTaskResult() when $default != null:
return $default(_that.dayKey,_that.day,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dayKey,  DateTime day,  List<FocusItem> items)  $default,) {final _that = this;
switch (_that) {
case _DailyTaskResult():
return $default(_that.dayKey,_that.day,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dayKey,  DateTime day,  List<FocusItem> items)?  $default,) {final _that = this;
switch (_that) {
case _DailyTaskResult() when $default != null:
return $default(_that.dayKey,_that.day,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyTaskResult extends DailyTaskResult {
  const _DailyTaskResult({required this.dayKey, required this.day,  List<FocusItem> items = const <FocusItem>[]}): _items = items,super._();
  factory _DailyTaskResult.fromJson(Map<String, dynamic> json) => _$DailyTaskResultFromJson(json);

@override final  String dayKey;
@override final  DateTime day;
 final  List<FocusItem> _items;
@override@JsonKey() List<FocusItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of DailyTaskResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyTaskResultCopyWith<_DailyTaskResult> get copyWith => __$DailyTaskResultCopyWithImpl<_DailyTaskResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyTaskResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyTaskResult&&(identical(other.dayKey, dayKey) || other.dayKey == dayKey)&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dayKey,day,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'DailyTaskResult(dayKey: $dayKey, day: $day, items: $items)';
}


}

/// @nodoc
abstract mixin class _$DailyTaskResultCopyWith<$Res> implements $DailyTaskResultCopyWith<$Res> {
  factory _$DailyTaskResultCopyWith(_DailyTaskResult value, $Res Function(_DailyTaskResult) _then) = __$DailyTaskResultCopyWithImpl;
@override @useResult
$Res call({
 String dayKey, DateTime day, List<FocusItem> items
});




}
/// @nodoc
class __$DailyTaskResultCopyWithImpl<$Res>
    implements _$DailyTaskResultCopyWith<$Res> {
  __$DailyTaskResultCopyWithImpl(this._self, this._then);

  final _DailyTaskResult _self;
  final $Res Function(_DailyTaskResult) _then;

/// Create a copy of DailyTaskResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayKey = null,Object? day = null,Object? items = null,}) {
  return _then(_DailyTaskResult(
dayKey: null == dayKey ? _self.dayKey : dayKey // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FocusItem>,
  ));
}


}

// dart format on
