//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_point.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_query_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_kpi.g.dart';

/// AnalyticsKpi
///
/// Properties:
/// * [key] - net_sales | margin_pct | orders | average_ticket | collected_today | collected | refunds | cost_coverage | stock_value
/// * [value]
/// * [comparison]
/// * [change]
/// * [changePct]
/// * [sparkline]
/// * [drill]
@BuiltValue()
abstract class AnalyticsKpi
    implements Built<AnalyticsKpi, AnalyticsKpiBuilder> {
  /// net_sales | margin_pct | orders | average_ticket | collected_today | collected | refunds | cost_coverage | stock_value
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'value')
  String? get value;

  @BuiltValueField(wireName: r'comparison')
  String? get comparison;

  @BuiltValueField(wireName: r'change')
  String? get change;

  @BuiltValueField(wireName: r'change_pct')
  String? get changePct;

  @BuiltValueField(wireName: r'sparkline')
  BuiltList<AnalyticsPoint> get sparkline;

  @BuiltValueField(wireName: r'drill')
  AnalyticsQueryRequest get drill;

  AnalyticsKpi._();

  factory AnalyticsKpi([void updates(AnalyticsKpiBuilder b)]) = _$AnalyticsKpi;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsKpiBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsKpi> get serializer => _$AnalyticsKpiSerializer();
}

class _$AnalyticsKpiSerializer implements PrimitiveSerializer<AnalyticsKpi> {
  @override
  final Iterable<Type> types = const [AnalyticsKpi, _$AnalyticsKpi];

  @override
  final String wireName = r'AnalyticsKpi';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsKpi object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield object.value == null
        ? null
        : serializers.serialize(
            object.value,
            specifiedType: const FullType.nullable(String),
          );
    yield r'comparison';
    yield object.comparison == null
        ? null
        : serializers.serialize(
            object.comparison,
            specifiedType: const FullType.nullable(String),
          );
    yield r'change';
    yield object.change == null
        ? null
        : serializers.serialize(
            object.change,
            specifiedType: const FullType.nullable(String),
          );
    yield r'change_pct';
    yield object.changePct == null
        ? null
        : serializers.serialize(
            object.changePct,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sparkline';
    yield serializers.serialize(
      object.sparkline,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsPoint)]),
    );
    yield r'drill';
    yield serializers.serialize(
      object.drill,
      specifiedType: const FullType(AnalyticsQueryRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsKpi object, {
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
    required AnalyticsKpiBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.key = valueDes;
          break;
        case r'value':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.value = valueDes;
          break;
        case r'comparison':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comparison = valueDes;
          break;
        case r'change':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.change = valueDes;
          break;
        case r'change_pct':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.changePct = valueDes;
          break;
        case r'sparkline':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsPoint),
                    ]),
                  )
                  as BuiltList<AnalyticsPoint>;
          result.sparkline.replace(valueDes);
          break;
        case r'drill':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsQueryRequest),
                  )
                  as AnalyticsQueryRequest;
          result.drill.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsKpi deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsKpiBuilder();
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
