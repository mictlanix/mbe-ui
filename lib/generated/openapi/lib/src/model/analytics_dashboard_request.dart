//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/comparison.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_dashboard_request.g.dart';

/// AnalyticsDashboardRequest
///
/// Properties:
/// * [start]
/// * [end]
/// * [facility]
/// * [comparison]
@BuiltValue()
abstract class AnalyticsDashboardRequest
    implements
        Built<AnalyticsDashboardRequest, AnalyticsDashboardRequestBuilder> {
  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'comparison')
  Comparison? get comparison;
  // enum comparisonEnum {  previous_period,  same_period_last_year,  };

  AnalyticsDashboardRequest._();

  factory AnalyticsDashboardRequest([
    void updates(AnalyticsDashboardRequestBuilder b),
  ]) = _$AnalyticsDashboardRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDashboardRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDashboardRequest> get serializer =>
      _$AnalyticsDashboardRequestSerializer();
}

class _$AnalyticsDashboardRequestSerializer
    implements PrimitiveSerializer<AnalyticsDashboardRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDashboardRequest,
    _$AnalyticsDashboardRequest,
  ];

  @override
  final String wireName = r'AnalyticsDashboardRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDashboardRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(Date),
    );
    yield r'end';
    yield serializers.serialize(
      object.end,
      specifiedType: const FullType(Date),
    );
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.comparison != null) {
      yield r'comparison';
      yield serializers.serialize(
        object.comparison,
        specifiedType: const FullType.nullable(Comparison),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDashboardRequest object, {
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
    required AnalyticsDashboardRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.end = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'comparison':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Comparison),
                  )
                  as Comparison?;
          if (valueDes == null) continue;
          result.comparison = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDashboardRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDashboardRequestBuilder();
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
