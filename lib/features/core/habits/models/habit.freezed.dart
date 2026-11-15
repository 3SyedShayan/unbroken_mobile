// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Habit {

 String get id; String get name; String get emoji; String get colorHex; String get frequency; int get sortOrder; bool get isArchived; int get currentStreak; int get bestStreak; int get totalCheckIns; String? get lastCompletedDayKey; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);

  /// Serializes this Habit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Habit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.currentStreak, _this.currentStreak) || other.currentStreak == _this.currentStreak)&&(identical(other.bestStreak, _this.bestStreak) || other.bestStreak == _this.bestStreak)&&(identical(other.totalCheckIns, _this.totalCheckIns) || other.totalCheckIns == _this.totalCheckIns)&&(identical(other.lastCompletedDayKey, _this.lastCompletedDayKey) || other.lastCompletedDayKey == _this.lastCompletedDayKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Habit;
  return Object.hash(runtimeType,_this.id,_this.name,_this.emoji,_this.colorHex,_this.frequency,_this.sortOrder,_this.isArchived,_this.currentStreak,_this.bestStreak,_this.totalCheckIns,_this.lastCompletedDayKey,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Habit;
  return 'Habit(id: ${_this.id}, name: ${_this.name}, emoji: ${_this.emoji}, colorHex: ${_this.colorHex}, frequency: ${_this.frequency}, sortOrder: ${_this.sortOrder}, isArchived: ${_this.isArchived}, currentStreak: ${_this.currentStreak}, bestStreak: ${_this.bestStreak}, totalCheckIns: ${_this.totalCheckIns}, lastCompletedDayKey: ${_this.lastCompletedDayKey}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String emoji, String colorHex, String frequency, int sortOrder, bool isArchived, int currentStreak, int bestStreak, int totalCheckIns, String? lastCompletedDayKey, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$HabitCopyWithImpl<$Res>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._self, this._then);

  final Habit _self;
  final $Res Function(Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorHex = null,Object? frequency = null,Object? sortOrder = null,Object? isArchived = null,Object? currentStreak = null,Object? bestStreak = null,Object? totalCheckIns = null,Object? lastCompletedDayKey = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,totalCheckIns: null == totalCheckIns ? _self.totalCheckIns : totalCheckIns // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDayKey: freezed == lastCompletedDayKey ? _self.lastCompletedDayKey : lastCompletedDayKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Habit].
extension HabitPatterns on Habit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Habit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Habit value)  $default,){
final _that = this;
switch (_that) {
case _Habit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Habit value)?  $default,){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  String colorHex,  String frequency,  int sortOrder,  bool isArchived,  int currentStreak,  int bestStreak,  int totalCheckIns,  String? lastCompletedDayKey,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorHex,_that.frequency,_that.sortOrder,_that.isArchived,_that.currentStreak,_that.bestStreak,_that.totalCheckIns,_that.lastCompletedDayKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  String colorHex,  String frequency,  int sortOrder,  bool isArchived,  int currentStreak,  int bestStreak,  int totalCheckIns,  String? lastCompletedDayKey,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.name,_that.emoji,_that.colorHex,_that.frequency,_that.sortOrder,_that.isArchived,_that.currentStreak,_that.bestStreak,_that.totalCheckIns,_that.lastCompletedDayKey,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String emoji,  String colorHex,  String frequency,  int sortOrder,  bool isArchived,  int currentStreak,  int bestStreak,  int totalCheckIns,  String? lastCompletedDayKey,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorHex,_that.frequency,_that.sortOrder,_that.isArchived,_that.currentStreak,_that.bestStreak,_that.totalCheckIns,_that.lastCompletedDayKey,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Habit extends Habit {
  const _Habit({required this.id, required this.name, this.emoji = '', this.colorHex = HabitPalette.defaultColor, this.frequency = 'daily', this.sortOrder = 0, this.isArchived = false, this.currentStreak = 0, this.bestStreak = 0, this.totalCheckIns = 0, this.lastCompletedDayKey, required this.createdAt, this.updatedAt}): super._();
  factory _Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  String colorHex;
@override@JsonKey() final  String frequency;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int bestStreak;
@override@JsonKey() final  int totalCheckIns;
@override final  String? lastCompletedDayKey;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.totalCheckIns, totalCheckIns) || other.totalCheckIns == totalCheckIns)&&(identical(other.lastCompletedDayKey, lastCompletedDayKey) || other.lastCompletedDayKey == lastCompletedDayKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,emoji,colorHex,frequency,sortOrder,isArchived,currentStreak,bestStreak,totalCheckIns,lastCompletedDayKey,createdAt,updatedAt);
}

@override
String toString() {
    return 'Habit(id: $id, name: $name, emoji: $emoji, colorHex: $colorHex, frequency: $frequency, sortOrder: $sortOrder, isArchived: $isArchived, currentStreak: $currentStreak, bestStreak: $bestStreak, totalCheckIns: $totalCheckIns, lastCompletedDayKey: $lastCompletedDayKey, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String emoji, String colorHex, String frequency, int sortOrder, bool isArchived, int currentStreak, int bestStreak, int totalCheckIns, String? lastCompletedDayKey, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$HabitCopyWithImpl<$Res>
    implements _$HabitCopyWith<$Res> {
  __$HabitCopyWithImpl(this._self, this._then);

  final _Habit _self;
  final $Res Function(_Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorHex = null,Object? frequency = null,Object? sortOrder = null,Object? isArchived = null,Object? currentStreak = null,Object? bestStreak = null,Object? totalCheckIns = null,Object? lastCompletedDayKey = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,totalCheckIns: null == totalCheckIns ? _self.totalCheckIns : totalCheckIns // ignore: cast_nullable_to_non_nullable
as int,lastCompletedDayKey: freezed == lastCompletedDayKey ? _self.lastCompletedDayKey : lastCompletedDayKey // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
