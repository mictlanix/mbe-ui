//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_dashboard_request.dart';
import 'package:mbe_api_client/src/model/analytics_series.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_alert.dart';
import 'package:mbe_api_client/src/model/analytics_kpi.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_dashboard_response.g.dart';

/// AnalyticsDashboardResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [definition]
/// * [comparisonStart]
/// * [comparisonEnd]
/// * [kpis]
/// * [series]
/// * [alerts]
@BuiltValue()
abstract class AnalyticsDashboardResponse
    implements
        Built<AnalyticsDashboardResponse, AnalyticsDashboardResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'definition')
  AnalyticsDashboardRequest get definition;

  @BuiltValueField(wireName: r'comparison_start')
  Date get comparisonStart;

  @BuiltValueField(wireName: r'comparison_end')
  Date get comparisonEnd;

  @BuiltValueField(wireName: r'kpis')
  BuiltList<AnalyticsKpi> get kpis;

  @BuiltValueField(wireName: r'series')
  BuiltList<AnalyticsSeries> get series;

  @BuiltValueField(wireName: r'alerts')
  BuiltList<AnalyticsAlert> get alerts;

  AnalyticsDashboardResponse._();

  factory AnalyticsDashboardResponse([
    void updates(AnalyticsDashboardResponseBuilder b),
  ]) = _$AnalyticsDashboardResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDashboardResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDashboardResponse> get serializer =>
      _$AnalyticsDashboardResponseSerializer();
}

class _$AnalyticsDashboardResponseSerializer
    implements PrimitiveSerializer<AnalyticsDashboardResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDashboardResponse,
    _$AnalyticsDashboardResponse,
  ];

  @override
  final String wireName = r'AnalyticsDashboardResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDashboardResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'definition';
    yield serializers.serialize(
      object.definition,
      specifiedType: const FullType(AnalyticsDashboardRequest),
    );
    yield r'comparison_start';
    yield serializers.serialize(
      object.comparisonStart,
      specifiedType: const FullType(Date),
    );
    yield r'comparison_end';
    yield serializers.serialize(
      object.comparisonEnd,
      specifiedType: const FullType(Date),
    );
    yield r'kpis';
    yield serializers.serialize(
      object.kpis,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsKpi)]),
    );
    yield r'series';
    yield serializers.serialize(
      object.series,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsSeries)]),
    );
    yield r'alerts';
    yield serializers.serialize(
      object.alerts,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsAlert)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDashboardResponse object, {
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
    required AnalyticsDashboardResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'as_of':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.asOf = valueDes;
          break;
        case r'definition':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsDashboardRequest),
                  )
                  as AnalyticsDashboardRequest;
          result.definition.replace(valueDes);
          break;
        case r'comparison_start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.comparisonStart = valueDes;
          break;
        case r'comparison_end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.comparisonEnd = valueDes;
          break;
        case r'kpis':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsKpi),
                    ]),
                  )
                  as BuiltList<AnalyticsKpi>;
          result.kpis.replace(valueDes);
          break;
        case r'series':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsSeries),
                    ]),
                  )
                  as BuiltList<AnalyticsSeries>;
          result.series.replace(valueDes);
          break;
        case r'alerts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsAlert),
                    ]),
                  )
                  as BuiltList<AnalyticsAlert>;
          result.alerts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDashboardResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDashboardResponseBuilder();
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
