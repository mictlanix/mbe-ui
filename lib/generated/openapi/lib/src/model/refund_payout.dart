//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_payout.g.dart';

/// How the customer gets their money back (FR-065).  A refundable order is always fully paid, so its balance is zero and the whole refund total is owed back — the only question is the form.
class RefundPayout extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash')
  static const RefundPayout cash = _$cash;
  @BuiltValueEnumConst(wireName: r'credit_note')
  static const RefundPayout creditNote = _$creditNote;

  static Serializer<RefundPayout> get serializer => _$refundPayoutSerializer;

  const RefundPayout._(String name) : super(name);

  static BuiltSet<RefundPayout> get values => _$values;
  static RefundPayout valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RefundPayoutMixin = Object with _$RefundPayoutMixin;
