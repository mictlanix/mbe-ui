//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/cadence.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/export_format.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_schedule_create.g.dart';

/// AnalyticsScheduleCreate
///
/// Properties:
/// * [analyticsView] - One of the caller's own views.
/// * [cadence]
/// * [weekdays] - 1 (Monday) to 7; weekly only.
/// * [monthDay] - Monthly only; past the month's end, its last day.
/// * [timeOfDay] - Business time.
/// * [format]
/// * [subject]
/// * [recipients] - Active users who hold the view's families (and cost for a sensitive measure).
/// * [enabled]
@BuiltValue()
abstract class AnalyticsScheduleCreate
    implements Built<AnalyticsScheduleCreate, AnalyticsScheduleCreateBuilder> {
  /// One of the caller's own views.
  @BuiltValueField(wireName: r'analytics_view')
  int get analyticsView;

  @BuiltValueField(wireName: r'cadence')
  Cadence get cadence;
  // enum cadenceEnum {  daily,  weekly,  monthly,  };

  /// 1 (Monday) to 7; weekly only.
  @BuiltValueField(wireName: r'weekdays')
  BuiltList<int>? get weekdays;

  /// Monthly only; past the month's end, its last day.
  @BuiltValueField(wireName: r'month_day')
  int? get monthDay;

  /// Business time.
  @BuiltValueField(wireName: r'time_of_day')
  String get timeOfDay;

  @BuiltValueField(wireName: r'format')
  ExportFormat get format;
  // enum formatEnum {  xlsx,  pdf,  csv,  };

  @BuiltValueField(wireName: r'subject')
  String get subject;

  /// Active users who hold the view's families (and cost for a sensitive measure).
  @BuiltValueField(wireName: r'recipients')
  BuiltList<String>? get recipients;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  AnalyticsScheduleCreate._();

  factory AnalyticsScheduleCreate([
    void updates(AnalyticsScheduleCreateBuilder b),
  ]) = _$AnalyticsScheduleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsScheduleCreateBuilder b) => b
    ..weekdays = ListBuilder()
    ..recipients = ListBuilder()
    ..enabled = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsScheduleCreate> get serializer =>
      _$AnalyticsScheduleCreateSerializer();
}

class _$AnalyticsScheduleCreateSerializer
    implements PrimitiveSerializer<AnalyticsScheduleCreate> {
  @override
  final Iterable<Type> types = const [
    AnalyticsScheduleCreate,
    _$AnalyticsScheduleCreate,
  ];

  @override
  final String wireName = r'AnalyticsScheduleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsScheduleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.weekdays != null) {
      yield r'weekdays';
      yield serializers.serialize(
        object.weekdays,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
    if (object.monthDay != null) {
      yield r'month_day';
      yield serializers.serialize(
        object.monthDay,
        specifiedType: const FullType.nullable(int),
      );
    }
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
    if (object.recipients != null) {
      yield r'recipients';
      yield serializers.serialize(
        object.recipients,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsScheduleCreate object, {
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
    required AnalyticsScheduleCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  AnalyticsScheduleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsScheduleCreateBuilder();
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
