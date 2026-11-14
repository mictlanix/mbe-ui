//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_detail_figures.g.dart';

/// A kind's own columns (spec 038), as decimal strings or ISO dates; null where not known.
///
/// Properties:
/// * [values] - stock: on_hand, reserved, available, in_transit, velocity, cover, reorder_point, suggested, last_movement, value (cost privilege only) | movements: movement_type, source, reference | receivables: balance, exchange_rate, due_date, days_past_due, bucket, due_bucket | invoices: type, status, issuer, uuid, issued, stamped, cancelled, subtotal, vat, total | uninvoiced_lines: sold, invoiced, invoiced_amount, first_invoiced, lag_days | commission_lines: month, status, movement, scheme, sales_order, sales_order_detail, customer_refund_detail, order_date, paid_date, product, label, label_name, label_rate, participation, participation_name, participation_rate, rate, price, base, share, full_commission, amount | purchases: supplier, supplier_name, unit_price, previous_price, change, change_pct, received
@BuiltValue()
abstract class AnalyticsDetailFigures
    implements Built<AnalyticsDetailFigures, AnalyticsDetailFiguresBuilder> {
  /// stock: on_hand, reserved, available, in_transit, velocity, cover, reorder_point, suggested, last_movement, value (cost privilege only) | movements: movement_type, source, reference | receivables: balance, exchange_rate, due_date, days_past_due, bucket, due_bucket | invoices: type, status, issuer, uuid, issued, stamped, cancelled, subtotal, vat, total | uninvoiced_lines: sold, invoiced, invoiced_amount, first_invoiced, lag_days | commission_lines: month, status, movement, scheme, sales_order, sales_order_detail, customer_refund_detail, order_date, paid_date, product, label, label_name, label_rate, participation, participation_name, participation_rate, rate, price, base, share, full_commission, amount | purchases: supplier, supplier_name, unit_price, previous_price, change, change_pct, received
  @BuiltValueField(wireName: r'values')
  BuiltMap<String, String?> get values;

  AnalyticsDetailFigures._();

  factory AnalyticsDetailFigures([
    void updates(AnalyticsDetailFiguresBuilder b),
  ]) = _$AnalyticsDetailFigures;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDetailFiguresBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDetailFigures> get serializer =>
      _$AnalyticsDetailFiguresSerializer();
}

class _$AnalyticsDetailFiguresSerializer
    implements PrimitiveSerializer<AnalyticsDetailFigures> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDetailFigures,
    _$AnalyticsDetailFigures,
  ];

  @override
  final String wireName = r'AnalyticsDetailFigures';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDetailFigures object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'values';
    yield serializers.serialize(
      object.values,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType.nullable(String),
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDetailFigures object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnalyticsDetailFiguresBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'values':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>;
          result.values.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDetailFigures deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDetailFiguresBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
