//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/measure_key.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/dimension_key.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_measure.g.dart';

/// AnalyticsMeasure
///
/// Properties:
/// * [key]
/// * [label]
/// * [unit] - money | quantity | count | ratio
/// * [sensitive] - Needs the cost privilege (37, 38 or 39).
/// * [vat] - Whether `vat=included` changes it.
/// * [additive] - False for ratios, recomputed from their parts.
/// * [dimensions] - The dimensions it can be grouped by.
@BuiltValue()
abstract class AnalyticsMeasure
    implements Built<AnalyticsMeasure, AnalyticsMeasureBuilder> {
  @BuiltValueField(wireName: r'key')
  MeasureKey get key;
  // enum keyEnum {  gross_sales,  discounts,  refunds,  credit_notes,  net_sales,  costed_net_sales,  cost_coverage,  cost_of_sales,  gross_margin,  margin_pct,  units_sold,  units_refunded,  units,  orders,  average_ticket,  collected,  refunds_paid_out,  store_credit_issued,  payments,  };

  @BuiltValueField(wireName: r'label')
  String get label;

  /// money | quantity | count | ratio
  @BuiltValueField(wireName: r'unit')
  String get unit;

  /// Needs the cost privilege (37, 38 or 39).
  @BuiltValueField(wireName: r'sensitive')
  bool get sensitive;

  /// Whether `vat=included` changes it.
  @BuiltValueField(wireName: r'vat')
  bool get vat;

  /// False for ratios, recomputed from their parts.
  @BuiltValueField(wireName: r'additive')
  bool get additive;

  /// The dimensions it can be grouped by.
  @BuiltValueField(wireName: r'dimensions')
  BuiltList<DimensionKey> get dimensions;

  AnalyticsMeasure._();

  factory AnalyticsMeasure([void updates(AnalyticsMeasureBuilder b)]) =
      _$AnalyticsMeasure;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsMeasureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsMeasure> get serializer =>
      _$AnalyticsMeasureSerializer();
}

class _$AnalyticsMeasureSerializer
    implements PrimitiveSerializer<AnalyticsMeasure> {
  @override
  final Iterable<Type> types = const [AnalyticsMeasure, _$AnalyticsMeasure];

  @override
  final String wireName = r'AnalyticsMeasure';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsMeasure object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(MeasureKey),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
    yield r'sensitive';
    yield serializers.serialize(
      object.sensitive,
      specifiedType: const FullType(bool),
    );
    yield r'vat';
    yield serializers.serialize(
      object.vat,
      specifiedType: const FullType(bool),
    );
    yield r'additive';
    yield serializers.serialize(
      object.additive,
      specifiedType: const FullType(bool),
    );
    yield r'dimensions';
    yield serializers.serialize(
      object.dimensions,
      specifiedType: const FullType(BuiltList, [FullType(DimensionKey)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsMeasure object, {
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
    required AnalyticsMeasureBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(MeasureKey),
                  )
                  as MeasureKey;
          result.key = valueDes;
          break;
        case r'label':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.label = valueDes;
          break;
        case r'unit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.unit = valueDes;
          break;
        case r'sensitive':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.sensitive = valueDes;
          break;
        case r'vat':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.vat = valueDes;
          break;
        case r'additive':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.additive = valueDes;
          break;
        case r'dimensions':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(DimensionKey),
                    ]),
                  )
                  as BuiltList<DimensionKey>;
          result.dimensions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsMeasure deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsMeasureBuilder();
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
