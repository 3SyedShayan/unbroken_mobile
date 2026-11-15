// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entry {

 String get id; String get habitId; String get logicalDayKey; String get source; String get platform; DateTime get timestamp;
/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCopyWith<Entry> get copyWith => _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Entry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.habitId, _this.habitId) || other.habitId == _this.habitId)&&(identical(other.logicalDayKey, _this.logicalDayKey) || other.logicalDayKey == _this.logicalDayKey)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Entry;
  return Object.hash(runtimeType,_this.id,_this.habitId,_this.logicalDayKey,_this.source,_this.platform,_this.timestamp);
}

@override
String toString() {
  final _this = this as Entry;
  return 'Entry(id: ${_this.id}, habitId: ${_this.habitId}, logicalDayKey: ${_this.logicalDayKey}, source: ${_this.source}, platform: ${_this.platform}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res>  {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) = _$EntryCopyWithImpl;
@useResult
$Res call({
 String id, String habitId, String logicalDayKey, String source, String platform, DateTime timestamp
});




}
/// @nodoc
class _$EntryCopyWithImpl<$Res>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? habitId = null,Object? logicalDayKey = null,Object? source = null,Object? platform = null,Object? timestamp = null,}) {
  return _then(Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,logicalDayKey: null == logicalDayKey ? _self.logicalDayKey : logicalDayKey // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entry value)  $default,){
final _that = this;
switch (_that) {
case _Entry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entry value)?  $default,){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String habitId,  String logicalDayKey,  String source,  String platform,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.habitId,_that.logicalDayKey,_that.source,_that.platform,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String habitId,  String logicalDayKey,  String source,  String platform,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _Entry():
return $default(_that.id,_that.habitId,_that.logicalDayKey,_that.source,_that.platform,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String habitId,  String logicalDayKey,  String source,  String platform,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.habitId,_that.logicalDayKey,_that.source,_that.platform,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entry extends Entry {
  const _Entry({required this.id, required this.habitId, required this.logicalDayKey, this.source = 'mobile', this.platform = 'ios', required this.timestamp}): super._();
  factory _Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

@override final  String id;
@override final  String habitId;
@override final  String logicalDayKey;
@override@JsonKey() final  String source;
@override@JsonKey() final  String platform;
@override final  DateTime timestamp;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCopyWith<_Entry> get copyWith => __$EntryCopyWithImpl<_Entry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entry&&(identical(other.id, id) || other.id == id)&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.logicalDayKey, logicalDayKey) || other.logicalDayKey == logicalDayKey)&&(identical(other.source, source) || other.source == source)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,habitId,logicalDayKey,source,platform,timestamp);
}

@override
String toString() {
    return 'Entry(id: $id, habitId: $habitId, logicalDayKey: $logicalDayKey, source: $source, platform: $platform, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) = __$EntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String habitId, String logicalDayKey, String source, String platform, DateTime timestamp
});




}
/// @nodoc
class __$EntryCopyWithImpl<$Res>
    implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? habitId = null,Object? logicalDayKey = null,Object? source = null,Object? platform = null,Object? timestamp = null,}) {
  return _then(_Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,logicalDayKey: null == logicalDayKey ? _self.logicalDayKey : logicalDayKey // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
