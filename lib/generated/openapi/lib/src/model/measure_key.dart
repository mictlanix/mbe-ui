//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'measure_key.g.dart';

class MeasureKey extends EnumClass {
  @BuiltValueEnumConst(wireName: r'gross_sales')
  static const MeasureKey grossSales = _$grossSales;
  @BuiltValueEnumConst(wireName: r'discounts')
  static const MeasureKey discounts = _$discounts;
  @BuiltValueEnumConst(wireName: r'refunds')
  static const MeasureKey refunds = _$refunds;
  @BuiltValueEnumConst(wireName: r'credit_notes')
  static const MeasureKey creditNotes = _$creditNotes;
  @BuiltValueEnumConst(wireName: r'net_sales')
  static const MeasureKey netSales = _$netSales;
  @BuiltValueEnumConst(wireName: r'costed_net_sales')
  static const MeasureKey costedNetSales = _$costedNetSales;
  @BuiltValueEnumConst(wireName: r'cost_coverage')
  static const MeasureKey costCoverage = _$costCoverage;
  @BuiltValueEnumConst(wireName: r'cost_of_sales')
  static const MeasureKey costOfSales = _$costOfSales;
  @BuiltValueEnumConst(wireName: r'gross_margin')
  static const MeasureKey grossMargin = _$grossMargin;
  @BuiltValueEnumConst(wireName: r'margin_pct')
  static const MeasureKey marginPct = _$marginPct;
  @BuiltValueEnumConst(wireName: r'units_sold')
  static const MeasureKey unitsSold = _$unitsSold;
  @BuiltValueEnumConst(wireName: r'units_refunded')
  static const MeasureKey unitsRefunded = _$unitsRefunded;
  @BuiltValueEnumConst(wireName: r'units')
  static const MeasureKey units = _$units;
  @BuiltValueEnumConst(wireName: r'orders')
  static const MeasureKey orders = _$orders;
  @BuiltValueEnumConst(wireName: r'average_ticket')
  static const MeasureKey averageTicket = _$averageTicket;
  @BuiltValueEnumConst(wireName: r'collected')
  static const MeasureKey collected = _$collected;
  @BuiltValueEnumConst(wireName: r'refunds_paid_out')
  static const MeasureKey refundsPaidOut = _$refundsPaidOut;
  @BuiltValueEnumConst(wireName: r'store_credit_issued')
  static const MeasureKey storeCreditIssued = _$storeCreditIssued;
  @BuiltValueEnumConst(wireName: r'payments')
  static const MeasureKey payments = _$payments;

  static Serializer<MeasureKey> get serializer => _$measureKeySerializer;

  const MeasureKey._(String name) : super(name);

  static BuiltSet<MeasureKey> get values => _$values;
  static MeasureKey valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class MeasureKeyMixin = Object with _$MeasureKeyMixin;
