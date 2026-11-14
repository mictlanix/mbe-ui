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

part 'analytics_view_response.g.dart';

/// AnalyticsViewResponse
///
/// Properties:
/// * [analyticsViewId]
/// * [name]
/// * [kind]
/// * [owner]
/// * [definition]
/// * [period]
/// * [sharedWith] - Shown to the owner only; empty for shared users.
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [modificationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class AnalyticsViewResponse
    implements Built<AnalyticsViewResponse, AnalyticsViewResponseBuilder> {
  @BuiltValueField(wireName: r'analytics_view_id')
  int get analyticsViewId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  ViewKind get kind;
  // enum kindEnum {  query,  dashboard,  detail,  customer,  };

  @BuiltValueField(wireName: r'owner')
  String get owner;

  @BuiltValueField(wireName: r'definition')
  BuiltMap<String, JsonObject?> get definition;

  @BuiltValueField(wireName: r'period')
  AnalyticsPeriod get period;

  /// Shown to the owner only; empty for shared users.
  @BuiltValueField(wireName: r'shared_with')
  BuiltList<String> get sharedWith;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  AnalyticsViewResponse._();

  factory AnalyticsViewResponse([
    void updates(AnalyticsViewResponseBuilder b),
  ]) = _$AnalyticsViewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsViewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsViewResponse> get serializer =>
      _$AnalyticsViewResponseSerializer();
}

class _$AnalyticsViewResponseSerializer
    implements PrimitiveSerializer<AnalyticsViewResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsViewResponse,
    _$AnalyticsViewResponse,
  ];

  @override
  final String wireName = r'AnalyticsViewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsViewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'analytics_view_id';
    yield serializers.serialize(
      object.analyticsViewId,
      specifiedType: const FullType(int),
    );
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
    yield r'owner';
    yield serializers.serialize(
      object.owner,
      specifiedType: const FullType(String),
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
    yield r'shared_with';
    yield serializers.serialize(
      object.sharedWith,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsViewResponse object, {
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
    required AnalyticsViewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'analytics_view_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.analyticsViewId = valueDes;
          break;
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
        case r'owner':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.owner = valueDes;
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
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.sharedWith.replace(valueDes);
          break;
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'modification_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.modificationTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsViewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsViewResponseBuilder();
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
