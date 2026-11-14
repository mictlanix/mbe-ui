//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'family.g.dart';

/// The analytics families (FR-060); the catalog maps each to the privileges that open it.
class Family extends EnumClass {
  @BuiltValueEnumConst(wireName: r'sales')
  static const Family sales = _$sales;
  @BuiltValueEnumConst(wireName: r'cost')
  static const Family cost = _$cost;
  @BuiltValueEnumConst(wireName: r'payments')
  static const Family payments = _$payments;
  @BuiltValueEnumConst(wireName: r'bulk')
  static const Family bulk = _$bulk;
  @BuiltValueEnumConst(wireName: r'inventory')
  static const Family inventory = _$inventory;
  @BuiltValueEnumConst(wireName: r'receivables')
  static const Family receivables = _$receivables;
  @BuiltValueEnumConst(wireName: r'payables')
  static const Family payables = _$payables;
  @BuiltValueEnumConst(wireName: r'commissions')
  static const Family commissions = _$commissions;
  @BuiltValueEnumConst(wireName: r'fiscal')
  static const Family fiscal = _$fiscal;
  @BuiltValueEnumConst(wireName: r'purchases')
  static const Family purchases = _$purchases;

  static Serializer<Family> get serializer => _$familySerializer;

  const Family._(String name) : super(name);

  static BuiltSet<Family> get values => _$values;
  static Family valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FamilyMixin = Object with _$FamilyMixin;
