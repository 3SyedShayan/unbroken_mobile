// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'focus_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FocusItem {

 String get id; String get text; bool get done;
/// Create a copy of FocusItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusItemCopyWith<FocusItem> get copyWith => _$FocusItemCopyWithImpl<FocusItem>(this as FocusItem, _$identity);

  /// Serializes this FocusItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FocusItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.done, _this.done) || other.done == _this.done));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FocusItem;
  return Object.hash(runtimeType,_this.id,_this.text,_this.done);
}

@override
String toString() {
  final _this = this as FocusItem;
  return 'FocusItem(id: ${_this.id}, text: ${_this.text}, done: ${_this.done})';
}


}

/// @nodoc
abstract mixin class $FocusItemCopyWith<$Res>  {
  factory $FocusItemCopyWith(FocusItem value, $Res Function(FocusItem) _then) = _$FocusItemCopyWithImpl;
@useResult
$Res call({
 String id, String text, bool done
});




}
/// @nodoc
class _$FocusItemCopyWithImpl<$Res>
    implements $FocusItemCopyWith<$Res> {
  _$FocusItemCopyWithImpl(this._self, this._then);

  final FocusItem _self;
  final $Res Function(FocusItem) _then;

/// Create a copy of FocusItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? done = null,}) {
  return _then(FocusItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FocusItem].
extension FocusItemPatterns on FocusItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusItem value)  $default,){
final _that = this;
switch (_that) {
case _FocusItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusItem value)?  $default,){
final _that = this;
switch (_that) {
case _FocusItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  bool done)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusItem() when $default != null:
return $default(_that.id,_that.text,_that.done);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  bool done)  $default,) {final _that = this;
switch (_that) {
case _FocusItem():
return $default(_that.id,_that.text,_that.done);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  bool done)?  $default,) {final _that = this;
switch (_that) {
case _FocusItem() when $default != null:
return $default(_that.id,_that.text,_that.done);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FocusItem implements FocusItem {
  const _FocusItem({required this.id, this.text = '', this.done = false});
  factory _FocusItem.fromJson(Map<String, dynamic> json) => _$FocusItemFromJson(json);

@override final  String id;
@override@JsonKey() final  String text;
@override@JsonKey() final  bool done;

/// Create a copy of FocusItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusItemCopyWith<_FocusItem> get copyWith => __$FocusItemCopyWithImpl<_FocusItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FocusItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.done, done) || other.done == done));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,text,done);
}

@override
String toString() {
    return 'FocusItem(id: $id, text: $text, done: $done)';
}


}

/// @nodoc
abstract mixin class _$FocusItemCopyWith<$Res> implements $FocusItemCopyWith<$Res> {
  factory _$FocusItemCopyWith(_FocusItem value, $Res Function(_FocusItem) _then) = __$FocusItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, bool done
});




}
/// @nodoc
class __$FocusItemCopyWithImpl<$Res>
    implements _$FocusItemCopyWith<$Res> {
  __$FocusItemCopyWithImpl(this._self, this._then);

  final _FocusItem _self;
  final $Res Function(_FocusItem) _then;

/// Create a copy of FocusItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? done = null,}) {
  return _then(_FocusItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
