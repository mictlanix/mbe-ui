//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'entity_status.g.dart';

class EntityStatus extends EnumClass {
  /// Unified lifecycle state shared by all status-bearing entities.
  @BuiltValueEnumConst(wireNumber: 0)
  static const EntityStatus number0 = _$number0;

  /// Unified lifecycle state shared by all status-bearing entities.
  @BuiltValueEnumConst(wireNumber: 1)
  static const EntityStatus number1 = _$number1;

  /// Unified lifecycle state shared by all status-bearing entities.
  @BuiltValueEnumConst(wireNumber: 2)
  static const EntityStatus number2 = _$number2;

  static Serializer<EntityStatus> get serializer => _$entityStatusSerializer;

  const EntityStatus._(String name) : super(name);

  static BuiltSet<EntityStatus> get values => _$values;
  static EntityStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class EntityStatusMixin = Object with _$EntityStatusMixin;
