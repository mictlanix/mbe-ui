//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_period.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_view_update.g.dart';

/// AnalyticsViewUpdate
///
/// Properties:
/// * [name]
/// * [definition]
/// * [period]
/// * [sharedWith] - Replaces the list.
@BuiltValue()
abstract class AnalyticsViewUpdate
    implements Built<AnalyticsViewUpdate, AnalyticsViewUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'definition')
  BuiltMap<String, JsonObject?>? get definition;

  @BuiltValueField(wireName: r'period')
  AnalyticsPeriod? get period;

  /// Replaces the list.
  @BuiltValueField(wireName: r'shared_with')
  BuiltList<String>? get sharedWith;

  AnalyticsViewUpdate._();

  factory AnalyticsViewUpdate([void updates(AnalyticsViewUpdateBuilder b)]) =
      _$AnalyticsViewUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsViewUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsViewUpdate> get serializer =>
      _$AnalyticsViewUpdateSerializer();
}

class _$AnalyticsViewUpdateSerializer
    implements PrimitiveSerializer<AnalyticsViewUpdate> {
  @override
  final Iterable<Type> types = const [
    AnalyticsViewUpdate,
    _$AnalyticsViewUpdate,
  ];

  @override
  final String wireName = r'AnalyticsViewUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsViewUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.definition != null) {
      yield r'definition';
      yield serializers.serialize(
        object.definition,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
    if (object.period != null) {
      yield r'period';
      yield serializers.serialize(
        object.period,
        specifiedType: const FullType.nullable(AnalyticsPeriod),
      );
    }
    if (object.sharedWith != null) {
      yield r'shared_with';
      yield serializers.serialize(
        object.sharedWith,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsViewUpdate object, {
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
    required AnalyticsViewUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'definition':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.definition.replace(valueDes);
          break;
        case r'period':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(AnalyticsPeriod),
                  )
                  as AnalyticsPeriod?;
          if (valueDes == null) continue;
          result.period.replace(valueDes);
          break;
        case r'shared_with':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>?;
          if (valueDes == null) continue;
          result.sharedWith.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsViewUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsViewUpdateBuilder();
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
