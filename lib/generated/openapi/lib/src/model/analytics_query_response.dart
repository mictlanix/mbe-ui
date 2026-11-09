//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_query_request.dart';
import 'package:mbe_api_client/src/model/analytics_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_query_response.g.dart';

/// AnalyticsQueryResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [definition]
/// * [rows]
/// * [others]
/// * [totals]
/// * [overlapping] - True when one document can count in several rows (grouped by label, or orders by a line dimension), so rows can add up to more than the totals.
@BuiltValue()
abstract class AnalyticsQueryResponse
    implements Built<AnalyticsQueryResponse, AnalyticsQueryResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'definition')
  AnalyticsQueryRequest get definition;

  @BuiltValueField(wireName: r'rows')
  BuiltList<AnalyticsRow> get rows;

  @BuiltValueField(wireName: r'others')
  AnalyticsRow? get others;

  @BuiltValueField(wireName: r'totals')
  AnalyticsRow get totals;

  /// True when one document can count in several rows (grouped by label, or orders by a line dimension), so rows can add up to more than the totals.
  @BuiltValueField(wireName: r'overlapping')
  bool get overlapping;

  AnalyticsQueryResponse._();

  factory AnalyticsQueryResponse([
    void updates(AnalyticsQueryResponseBuilder b),
  ]) = _$AnalyticsQueryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsQueryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsQueryResponse> get serializer =>
      _$AnalyticsQueryResponseSerializer();
}

class _$AnalyticsQueryResponseSerializer
    implements PrimitiveSerializer<AnalyticsQueryResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsQueryResponse,
    _$AnalyticsQueryResponse,
  ];

  @override
  final String wireName = r'AnalyticsQueryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsQueryResponse object, {
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
      specifiedType: const FullType(AnalyticsQueryRequest),
    );
    yield r'rows';
    yield serializers.serialize(
      object.rows,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsRow)]),
    );
    if (object.others != null) {
      yield r'others';
      yield serializers.serialize(
        object.others,
        specifiedType: const FullType.nullable(AnalyticsRow),
      );
    }
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(AnalyticsRow),
    );
    yield r'overlapping';
    yield serializers.serialize(
      object.overlapping,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsQueryResponse object, {
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
    required AnalyticsQueryResponseBuilder result,
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
                    specifiedType: const FullType(AnalyticsQueryRequest),
                  )
                  as AnalyticsQueryRequest;
          result.definition.replace(valueDes);
          break;
        case r'rows':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsRow),
                    ]),
                  )
                  as BuiltList<AnalyticsRow>;
          result.rows.replace(valueDes);
          break;
        case r'others':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(AnalyticsRow),
                  )
                  as AnalyticsRow?;
          if (valueDes == null) continue;
          result.others.replace(valueDes);
          break;
        case r'totals':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AnalyticsRow),
                  )
                  as AnalyticsRow;
          result.totals.replace(valueDes);
          break;
        case r'overlapping':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.overlapping = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsQueryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsQueryResponseBuilder();
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
