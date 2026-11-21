// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoalFolder {

 String get id; String get name; GoalCadence get cadence; String get emoji; String get colorHex; int get sortOrder; bool get isArchived; String? get periodKey; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of GoalFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalFolderCopyWith<GoalFolder> get copyWith => _$GoalFolderCopyWithImpl<GoalFolder>(this as GoalFolder, _$identity);

  /// Serializes this GoalFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoalFolder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalFolder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cadence, _this.cadence) || other.cadence == _this.cadence)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.periodKey, _this.periodKey) || other.periodKey == _this.periodKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoalFolder;
  return Object.hash(runtimeType,_this.id,_this.name,_this.cadence,_this.emoji,_this.colorHex,_this.sortOrder,_this.isArchived,_this.periodKey,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as GoalFolder;
  return 'GoalFolder(id: ${_this.id}, name: ${_this.name}, cadence: ${_this.cadence}, emoji: ${_this.emoji}, colorHex: ${_this.colorHex}, sortOrder: ${_this.sortOrder}, isArchived: ${_this.isArchived}, periodKey: ${_this.periodKey}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $GoalFolderCopyWith<$Res>  {
  factory $GoalFolderCopyWith(GoalFolder value, $Res Function(GoalFolder) _then) = _$GoalFolderCopyWithImpl;
@useResult
$Res call({
 String id, String name, GoalCadence cadence, String emoji, String colorHex, int sortOrder, bool isArchived, String? periodKey, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$GoalFolderCopyWithImpl<$Res>
    implements $GoalFolderCopyWith<$Res> {
  _$GoalFolderCopyWithImpl(this._self, this._then);

  final GoalFolder _self;
  final $Res Function(GoalFolder) _then;

/// Create a copy of GoalFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cadence = null,Object? emoji = null,Object? colorHex = null,Object? sortOrder = null,Object? isArchived = null,Object? periodKey = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(GoalFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cadence: null == cadence ? _self.cadence : cadence // ignore: cast_nullable_to_non_nullable
as GoalCadence,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalFolder].
extension GoalFolderPatterns on GoalFolder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalFolder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalFolder value)  $default,){
final _that = this;
switch (_that) {
case _GoalFolder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalFolder value)?  $default,){
final _that = this;
switch (_that) {
case _GoalFolder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  GoalCadence cadence,  String emoji,  String colorHex,  int sortOrder,  bool isArchived,  String? periodKey,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalFolder() when $default != null:
return $default(_that.id,_that.name,_that.cadence,_that.emoji,_that.colorHex,_that.sortOrder,_that.isArchived,_that.periodKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  GoalCadence cadence,  String emoji,  String colorHex,  int sortOrder,  bool isArchived,  String? periodKey,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GoalFolder():
return $default(_that.id,_that.name,_that.cadence,_that.emoji,_that.colorHex,_that.sortOrder,_that.isArchived,_that.periodKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  GoalCadence cadence,  String emoji,  String colorHex,  int sortOrder,  bool isArchived,  String? periodKey,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoalFolder() when $default != null:
return $default(_that.id,_that.name,_that.cadence,_that.emoji,_that.colorHex,_that.sortOrder,_that.isArchived,_that.periodKey,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalFolder extends GoalFolder {
  const _GoalFolder({required this.id, required this.name, required this.cadence, this.emoji = '', this.colorHex = '#E07A5F', this.sortOrder = 0, this.isArchived = false, this.periodKey, this.createdAt, this.updatedAt}): super._();
  factory _GoalFolder.fromJson(Map<String, dynamic> json) => _$GoalFolderFromJson(json);

@override final  String id;
@override final  String name;
@override final  GoalCadence cadence;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  String colorHex;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isArchived;
@override final  String? periodKey;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of GoalFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalFolderCopyWith<_GoalFolder> get copyWith => __$GoalFolderCopyWithImpl<_GoalFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalFolderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cadence, cadence) || other.cadence == cadence)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,cadence,emoji,colorHex,sortOrder,isArchived,periodKey,createdAt,updatedAt);
}

@override
String toString() {
    return 'GoalFolder(id: $id, name: $name, cadence: $cadence, emoji: $emoji, colorHex: $colorHex, sortOrder: $sortOrder, isArchived: $isArchived, periodKey: $periodKey, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GoalFolderCopyWith<$Res> implements $GoalFolderCopyWith<$Res> {
  factory _$GoalFolderCopyWith(_GoalFolder value, $Res Function(_GoalFolder) _then) = __$GoalFolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, GoalCadence cadence, String emoji, String colorHex, int sortOrder, bool isArchived, String? periodKey, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$GoalFolderCopyWithImpl<$Res>
    implements _$GoalFolderCopyWith<$Res> {
  __$GoalFolderCopyWithImpl(this._self, this._then);

  final _GoalFolder _self;
  final $Res Function(_GoalFolder) _then;

/// Create a copy of GoalFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cadence = null,Object? emoji = null,Object? colorHex = null,Object? sortOrder = null,Object? isArchived = null,Object? periodKey = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_GoalFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cadence: null == cadence ? _self.cadence : cadence // ignore: cast_nullable_to_non_nullable
as GoalCadence,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
