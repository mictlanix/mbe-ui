//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/cadence.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/export_format.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_schedule_response.g.dart';

/// AnalyticsScheduleResponse
///
/// Properties:
/// * [analyticsScheduleId]
/// * [analyticsView]
/// * [cadence]
/// * [weekdays]
/// * [monthDay]
/// * [timeOfDay]
/// * [format]
/// * [subject]
/// * [recipients]
/// * [enabled]
/// * [nextRunTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class AnalyticsScheduleResponse
    implements
        Built<AnalyticsScheduleResponse, AnalyticsScheduleResponseBuilder> {
  @BuiltValueField(wireName: r'analytics_schedule_id')
  int get analyticsScheduleId;

  @BuiltValueField(wireName: r'analytics_view')
  int get analyticsView;

  @BuiltValueField(wireName: r'cadence')
  Cadence get cadence;
  // enum cadenceEnum {  daily,  weekly,  monthly,  };

  @BuiltValueField(wireName: r'weekdays')
  BuiltList<int> get weekdays;

  @BuiltValueField(wireName: r'month_day')
  int? get monthDay;

  @BuiltValueField(wireName: r'time_of_day')
  String get timeOfDay;

  @BuiltValueField(wireName: r'format')
  ExportFormat get format;
  // enum formatEnum {  xlsx,  pdf,  csv,  };

  @BuiltValueField(wireName: r'subject')
  String get subject;

  @BuiltValueField(wireName: r'recipients')
  BuiltList<String> get recipients;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'next_run_time')
  DateTime get nextRunTime;

  AnalyticsScheduleResponse._();

  factory AnalyticsScheduleResponse([
    void updates(AnalyticsScheduleResponseBuilder b),
  ]) = _$AnalyticsScheduleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsScheduleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsScheduleResponse> get serializer =>
      _$AnalyticsScheduleResponseSerializer();
}

class _$AnalyticsScheduleResponseSerializer
    implements PrimitiveSerializer<AnalyticsScheduleResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsScheduleResponse,
    _$AnalyticsScheduleResponse,
  ];

  @override
  final String wireName = r'AnalyticsScheduleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsScheduleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'analytics_schedule_id';
    yield serializers.serialize(
      object.analyticsScheduleId,
      specifiedType: const FullType(int),
    );
    yield r'analytics_view';
    yield serializers.serialize(
      object.analyticsView,
      specifiedType: const FullType(int),
    );
    yield r'cadence';
    yield serializers.serialize(
      object.cadence,
      specifiedType: const FullType(Cadence),
    );
    yield r'weekdays';
    yield serializers.serialize(
      object.weekdays,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
    yield r'month_day';
    yield object.monthDay == null
        ? null
        : serializers.serialize(
            object.monthDay,
            specifiedType: const FullType.nullable(int),
          );
    yield r'time_of_day';
    yield serializers.serialize(
      object.timeOfDay,
      specifiedType: const FullType(String),
    );
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(ExportFormat),
    );
    yield r'subject';
    yield serializers.serialize(
      object.subject,
      specifiedType: const FullType(String),
    );
    yield r'recipients';
    yield serializers.serialize(
      object.recipients,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'next_run_time';
    yield serializers.serialize(
      object.nextRunTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsScheduleResponse object, {
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
    required AnalyticsScheduleResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'analytics_schedule_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.analyticsScheduleId = valueDes;
          break;
        case r'analytics_view':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.analyticsView = valueDes;
          break;
        case r'cadence':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Cadence),
                  )
                  as Cadence;
          result.cadence = valueDes;
          break;
        case r'weekdays':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [FullType(int)]),
                  )
                  as BuiltList<int>;
          result.weekdays.replace(valueDes);
          break;
        case r'month_day':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.monthDay = valueDes;
          break;
        case r'time_of_day':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.timeOfDay = valueDes;
          break;
        case r'format':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ExportFormat),
                  )
                  as ExportFormat;
          result.format = valueDes;
          break;
        case r'subject':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.subject = valueDes;
          break;
        case r'recipients':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.recipients.replace(valueDes);
          break;
        case r'enabled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.enabled = valueDes;
          break;
        case r'next_run_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.nextRunTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsScheduleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsScheduleResponseBuilder();
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
