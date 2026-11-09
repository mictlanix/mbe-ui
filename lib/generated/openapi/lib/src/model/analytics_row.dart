//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_filter.dart';
import 'package:mbe_api_client/src/model/analytics_key.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_row.g.dart';

/// AnalyticsRow
///
/// Properties:
/// * [keys]
/// * [values]
/// * [share]
/// * [comparison]
/// * [change]
/// * [changePct]
/// * [drill]
@BuiltValue()
abstract class AnalyticsRow
    implements Built<AnalyticsRow, AnalyticsRowBuilder> {
  @BuiltValueField(wireName: r'keys')
  BuiltList<AnalyticsKey> get keys;

  @BuiltValueField(wireName: r'values')
  BuiltMap<String, String?> get values;

  @BuiltValueField(wireName: r'share')
  BuiltMap<String, String?> get share;

  @BuiltValueField(wireName: r'comparison')
  BuiltMap<String, String?>? get comparison;

  @BuiltValueField(wireName: r'change')
  BuiltMap<String, String?>? get change;

  @BuiltValueField(wireName: r'change_pct')
  BuiltMap<String, String?>? get changePct;

  @BuiltValueField(wireName: r'drill')
  BuiltList<AnalyticsFilter> get drill;

  AnalyticsRow._();

  factory AnalyticsRow([void updates(AnalyticsRowBuilder b)]) = _$AnalyticsRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsRow> get serializer => _$AnalyticsRowSerializer();
}

class _$AnalyticsRowSerializer implements PrimitiveSerializer<AnalyticsRow> {
  @override
  final Iterable<Type> types = const [AnalyticsRow, _$AnalyticsRow];

  @override
  final String wireName = r'AnalyticsRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'keys';
    yield serializers.serialize(
      object.keys,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsKey)]),
    );
    yield r'values';
    yield serializers.serialize(
      object.values,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType.nullable(String),
      ]),
    );
    yield r'share';
    yield serializers.serialize(
      object.share,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType.nullable(String),
      ]),
    );
    if (object.comparison != null) {
      yield r'comparison';
      yield serializers.serialize(
        object.comparison,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(String),
        ]),
      );
    }
    if (object.change != null) {
      yield r'change';
      yield serializers.serialize(
        object.change,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(String),
        ]),
      );
    }
    if (object.changePct != null) {
      yield r'change_pct';
      yield serializers.serialize(
        object.changePct,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(String),
        ]),
      );
    }
    yield r'drill';
    yield serializers.serialize(
      object.drill,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsFilter)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsRow object, {
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
    required AnalyticsRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'keys':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsKey),
                    ]),
                  )
                  as BuiltList<AnalyticsKey>;
          result.keys.replace(valueDes);
          break;
        case r'values':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>;
          result.values.replace(valueDes);
          break;
        case r'share':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>;
          result.share.replace(valueDes);
          break;
        case r'comparison':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>?;
          if (valueDes == null) continue;
          result.comparison.replace(valueDes);
          break;
        case r'change':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>?;
          if (valueDes == null) continue;
          result.change.replace(valueDes);
          break;
        case r'change_pct':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(String),
                    ]),
                  )
                  as BuiltMap<String, String?>?;
          if (valueDes == null) continue;
          result.changePct.replace(valueDes);
          break;
        case r'drill':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsFilter),
                    ]),
                  )
                  as BuiltList<AnalyticsFilter>;
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
  AnalyticsRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsRowBuilder();
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
