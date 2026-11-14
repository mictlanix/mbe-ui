//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'detail_flag.g.dart';

class DetailFlag extends EnumClass {
  @BuiltValueEnumConst(wireName: r'overdue')
  static const DetailFlag overdue = _$overdue;
  @BuiltValueEnumConst(wireName: r'below_cost')
  static const DetailFlag belowCost = _$belowCost;
  @BuiltValueEnumConst(wireName: r'without_cost')
  static const DetailFlag withoutCost = _$withoutCost;
  @BuiltValueEnumConst(wireName: r'collected')
  static const DetailFlag collected = _$collected;
  @BuiltValueEnumConst(wireName: r'paid_out')
  static const DetailFlag paidOut = _$paidOut;
  @BuiltValueEnumConst(wireName: r'store_credit')
  static const DetailFlag storeCredit = _$storeCredit;
  @BuiltValueEnumConst(wireName: r'stock_out')
  static const DetailFlag stockOut = _$stockOut;
  @BuiltValueEnumConst(wireName: r'below_reorder')
  static const DetailFlag belowReorder = _$belowReorder;
  @BuiltValueEnumConst(wireName: r'dead')
  static const DetailFlag dead = _$dead;
  @BuiltValueEnumConst(wireName: r'slow')
  static const DetailFlag slow = _$slow;
  @BuiltValueEnumConst(wireName: r'uncosted')
  static const DetailFlag uncosted = _$uncosted;
  @BuiltValueEnumConst(wireName: r'price_change')
  static const DetailFlag priceChange = _$priceChange;

  static Serializer<DetailFlag> get serializer => _$detailFlagSerializer;

  const DetailFlag._(String name) : super(name);

  static BuiltSet<DetailFlag> get values => _$values;
  static DetailFlag valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DetailFlagMixin = Object with _$DetailFlagMixin;
