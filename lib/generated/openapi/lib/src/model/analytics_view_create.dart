//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/view_kind.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_period.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_view_create.g.dart';

/// AnalyticsViewCreate
///
/// Properties:
/// * [name] - Unique per owner.
/// * [kind]
/// * [definition] - The kind's request (query, dashboard, detail or customer 360) without `start` and `end`; the period gives them.
/// * [period]
/// * [sharedWith] - Active user ids.
@BuiltValue()
abstract class AnalyticsViewCreate
    implements Built<AnalyticsViewCreate, AnalyticsViewCreateBuilder> {
  /// Unique per owner.
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  ViewKind get kind;
  // enum kindEnum {  query,  dashboard,  detail,  customer,  };

  /// The kind's request (query, dashboard, detail or customer 360) without `start` and `end`; the period gives them.
  @BuiltValueField(wireName: r'definition')
  BuiltMap<String, JsonObject?> get definition;

  @BuiltValueField(wireName: r'period')
  AnalyticsPeriod get period;

  /// Active user ids.
  @BuiltValueField(wireName: r'shared_with')
  BuiltList<String?>? get sharedWith;

  AnalyticsViewCreate._();

  factory AnalyticsViewCreate([void updates(AnalyticsViewCreateBuilder b)]) =
      _$AnalyticsViewCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsViewCreateBuilder b) =>
      b..sharedWith = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsViewCreate> get serializer =>
      _$AnalyticsViewCreateSerializer();
}

class _$AnalyticsViewCreateSerializer
    implements PrimitiveSerializer<AnalyticsViewCreate> {
  @override
  final Iterable<Type> types = const [
    AnalyticsViewCreate,
    _$AnalyticsViewCreate,
  ];

  @override
  final String wireName = r'AnalyticsViewCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsViewCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ViewKind),
    );
    yield r'definition';
    yield serializers.serialize(
      object.definition,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType.nullable(JsonObject),
      ]),
    );
    yield r'period';
    yield serializers.serialize(
      object.period,
      specifiedType: const FullType(AnalyticsPeriod),
    );
    if (object.sharedWith != null) {
      yield r'shared_with';
      yield serializers.serialize(
        object.sharedWith,
        specifiedType: const FullType(BuiltList, [FullType.nullable(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsViewCreate object, {
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
    required AnalyticsViewCreateBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ViewKind),
                  )
                  as ViewKind;
          result.kind = valueDes;
          break;
        case r'definition':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>;
          result.definition.replace(valueDes);
          break;
        case r'period':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsPeriod),
                  )
                  as AnalyticsPeriod;
          result.period.replace(valueDes);
          break;
        case r'shared_with':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltList<String?>?;
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
  AnalyticsViewCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsViewCreateBuilder();
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
