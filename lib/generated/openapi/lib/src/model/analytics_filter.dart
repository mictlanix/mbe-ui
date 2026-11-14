//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/dimension_key.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_filter.g.dart';

/// AnalyticsFilter
///
/// Properties:
/// * [dimension]
/// * [values] - Ids for entity dimensions; the value for brand, model, customer_type (credit, cash), payment_terms (immediate, credit), weekday (1 = Monday), hour, issuer (RFC), aging_bucket (current, 1-30, 31-60, 61-90, 90+), due_bucket (overdue, 1-7, 8-30, 31-60, 60+), commission_status (provisional, closed), document_status (stamped, cancelled, pending) and document_type (invoice, credit_note, payment_receipt); the ISO date of the period start for date. An empty string selects \"none\".
@BuiltValue()
abstract class AnalyticsFilter
    implements Built<AnalyticsFilter, AnalyticsFilterBuilder> {
  @BuiltValueField(wireName: r'dimension')
  DimensionKey get dimension;
  // enum dimensionEnum {  date,  weekday,  hour,  facility,  point_of_sale,  salesperson,  cash_session,  customer,  customer_type,  product,  brand,  model,  label,  payment_terms,  payment_method,  warehouse,  movement_type,  supplier,  aging_bucket,  due_bucket,  sales_agent,  commission_participation,  commission_status,  issuer,  document_status,  document_type,  };

  /// Ids for entity dimensions; the value for brand, model, customer_type (credit, cash), payment_terms (immediate, credit), weekday (1 = Monday), hour, issuer (RFC), aging_bucket (current, 1-30, 31-60, 61-90, 90+), due_bucket (overdue, 1-7, 8-30, 31-60, 60+), commission_status (provisional, closed), document_status (stamped, cancelled, pending) and document_type (invoice, credit_note, payment_receipt); the ISO date of the period start for date. An empty string selects \"none\".
  @BuiltValueField(wireName: r'values')
  BuiltList<String> get values;

  AnalyticsFilter._();

  factory AnalyticsFilter([void updates(AnalyticsFilterBuilder b)]) =
      _$AnalyticsFilter;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsFilterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsFilter> get serializer =>
      _$AnalyticsFilterSerializer();
}

class _$AnalyticsFilterSerializer
    implements PrimitiveSerializer<AnalyticsFilter> {
  @override
  final Iterable<Type> types = const [AnalyticsFilter, _$AnalyticsFilter];

  @override
  final String wireName = r'AnalyticsFilter';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsFilter object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dimension';
    yield serializers.serialize(
      object.dimension,
      specifiedType: const FullType(DimensionKey),
    );
    yield r'values';
    yield serializers.serialize(
      object.values,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsFilter object, {
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
    required AnalyticsFilterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dimension':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DimensionKey),
                  )
                  as DimensionKey;
          result.dimension = valueDes;
          break;
        case r'values':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
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
  AnalyticsFilter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsFilterBuilder();
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
