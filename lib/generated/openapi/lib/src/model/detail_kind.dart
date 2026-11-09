//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'detail_kind.g.dart';

class DetailKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'orders')
  static const DetailKind orders = _$orders;
  @BuiltValueEnumConst(wireName: r'lines')
  static const DetailKind lines = _$lines;
  @BuiltValueEnumConst(wireName: r'refunds')
  static const DetailKind refunds = _$refunds;
  @BuiltValueEnumConst(wireName: r'credit_notes')
  static const DetailKind creditNotes = _$creditNotes;
  @BuiltValueEnumConst(wireName: r'payments')
  static const DetailKind payments = _$payments;

  static Serializer<DetailKind> get serializer => _$detailKindSerializer;

  const DetailKind._(String name) : super(name);

  static BuiltSet<DetailKind> get values => _$values;
  static DetailKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DetailKindMixin = Object with _$DetailKindMixin;
