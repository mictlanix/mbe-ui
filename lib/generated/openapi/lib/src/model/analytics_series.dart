//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_query_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_series.g.dart';

/// AnalyticsSeries
///
/// Properties:
/// * [key] - sales_over_time | sales_by_facility | sales_by_label | sales_by_brand | top_products | top_customers | payment_mix | heatmap | stock_value_by_facility
/// * [chart] - line | bar | donut | heatmap
/// * [query]
@BuiltValue()
abstract class AnalyticsSeries
    implements Built<AnalyticsSeries, AnalyticsSeriesBuilder> {
  /// sales_over_time | sales_by_facility | sales_by_label | sales_by_brand | top_products | top_customers | payment_mix | heatmap | stock_value_by_facility
  @BuiltValueField(wireName: r'key')
  String get key;

  /// line | bar | donut | heatmap
  @BuiltValueField(wireName: r'chart')
  String get chart;

  @BuiltValueField(wireName: r'query')
  AnalyticsQueryResponse get query;

  AnalyticsSeries._();

  factory AnalyticsSeries([void updates(AnalyticsSeriesBuilder b)]) =
      _$AnalyticsSeries;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsSeriesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsSeries> get serializer =>
      _$AnalyticsSeriesSerializer();
}

class _$AnalyticsSeriesSerializer
    implements PrimitiveSerializer<AnalyticsSeries> {
  @override
  final Iterable<Type> types = const [AnalyticsSeries, _$AnalyticsSeries];

  @override
  final String wireName = r'AnalyticsSeries';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsSeries object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'chart';
    yield serializers.serialize(
      object.chart,
      specifiedType: const FullType(String),
    );
    yield r'query';
    yield serializers.serialize(
      object.query,
      specifiedType: const FullType(AnalyticsQueryResponse),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsSeries object, {
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
    required AnalyticsSeriesBuilder result,
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
        case r'chart':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.chart = valueDes;
          break;
        case r'query':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsQueryResponse),
                  )
                  as AnalyticsQueryResponse;
          result.query.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsSeries deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsSeriesBuilder();
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
