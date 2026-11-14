//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/cadence.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/export_format.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_schedule_update.g.dart';

/// Only the fields given change. A cadence change clears the days that don't apply to it.
///
/// Properties:
/// * [cadence]
/// * [weekdays]
/// * [monthDay]
/// * [timeOfDay]
/// * [format]
/// * [subject]
/// * [recipients]
/// * [enabled]
@BuiltValue()
abstract class AnalyticsScheduleUpdate
    implements Built<AnalyticsScheduleUpdate, AnalyticsScheduleUpdateBuilder> {
  @BuiltValueField(wireName: r'cadence')
  Cadence? get cadence;
  // enum cadenceEnum {  daily,  weekly,  monthly,  };

  @BuiltValueField(wireName: r'weekdays')
  BuiltList<int>? get weekdays;

  @BuiltValueField(wireName: r'month_day')
  int? get monthDay;

  @BuiltValueField(wireName: r'time_of_day')
  String? get timeOfDay;

  @BuiltValueField(wireName: r'format')
  ExportFormat? get format;
  // enum formatEnum {  xlsx,  pdf,  csv,  };

  @BuiltValueField(wireName: r'subject')
  String? get subject;

  @BuiltValueField(wireName: r'recipients')
  BuiltList<String>? get recipients;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  AnalyticsScheduleUpdate._();

  factory AnalyticsScheduleUpdate([
    void updates(AnalyticsScheduleUpdateBuilder b),
  ]) = _$AnalyticsScheduleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsScheduleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsScheduleUpdate> get serializer =>
      _$AnalyticsScheduleUpdateSerializer();
}

class _$AnalyticsScheduleUpdateSerializer
    implements PrimitiveSerializer<AnalyticsScheduleUpdate> {
  @override
  final Iterable<Type> types = const [
    AnalyticsScheduleUpdate,
    _$AnalyticsScheduleUpdate,
  ];

  @override
  final String wireName = r'AnalyticsScheduleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsScheduleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cadence != null) {
      yield r'cadence';
      yield serializers.serialize(
        object.cadence,
        specifiedType: const FullType.nullable(Cadence),
      );
    }
    if (object.weekdays != null) {
      yield r'weekdays';
      yield serializers.serialize(
        object.weekdays,
        specifiedType: const FullType.nullable(BuiltList, [FullType(int)]),
      );
    }
    if (object.monthDay != null) {
      yield r'month_day';
      yield serializers.serialize(
        object.monthDay,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.timeOfDay != null) {
      yield r'time_of_day';
      yield serializers.serialize(
        object.timeOfDay,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.format != null) {
      yield r'format';
      yield serializers.serialize(
        object.format,
        specifiedType: const FullType.nullable(ExportFormat),
      );
    }
    if (object.subject != null) {
      yield r'subject';
      yield serializers.serialize(
        object.subject,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.recipients != null) {
      yield r'recipients';
      yield serializers.serialize(
        object.recipients,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsScheduleUpdate object, {
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
    required AnalyticsScheduleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cadence':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Cadence),
                  )
                  as Cadence?;
          if (valueDes == null) continue;
          result.cadence = valueDes;
          break;
        case r'weekdays':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(int),
                    ]),
                  )
                  as BuiltList<int>?;
          if (valueDes == null) continue;
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
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.timeOfDay = valueDes;
          break;
        case r'format':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(ExportFormat),
                  )
                  as ExportFormat?;
          if (valueDes == null) continue;
          result.format = valueDes;
          break;
        case r'subject':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.subject = valueDes;
          break;
        case r'recipients':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>?;
          if (valueDes == null) continue;
          result.recipients.replace(valueDes);
          break;
        case r'enabled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsScheduleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsScheduleUpdateBuilder();
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
