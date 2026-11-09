//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_detail_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_detail_response.g.dart';

/// AnalyticsDetailResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [items]
/// * [total]
/// * [sums] - amount, quantity, discount, and cost and margin for holders of the cost privilege, over every page: they equal the aggregate.
@BuiltValue()
abstract class AnalyticsDetailResponse
    implements Built<AnalyticsDetailResponse, AnalyticsDetailResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'items')
  BuiltList<AnalyticsDetailItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  /// amount, quantity, discount, and cost and margin for holders of the cost privilege, over every page: they equal the aggregate.
  @BuiltValueField(wireName: r'sums')
  BuiltMap<String, String> get sums;

  AnalyticsDetailResponse._();

  factory AnalyticsDetailResponse([
    void updates(AnalyticsDetailResponseBuilder b),
  ]) = _$AnalyticsDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDetailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDetailResponse> get serializer =>
      _$AnalyticsDetailResponseSerializer();
}

class _$AnalyticsDetailResponseSerializer
    implements PrimitiveSerializer<AnalyticsDetailResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDetailResponse,
    _$AnalyticsDetailResponse,
  ];

  @override
  final String wireName = r'AnalyticsDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsDetailItem)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'sums';
    yield serializers.serialize(
      object.sums,
      specifiedType: const FullType(BuiltMap, [
        FullType(String),
        FullType(String),
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDetailResponse object, {
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
    required AnalyticsDetailResponseBuilder result,
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
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsDetailItem),
                    ]),
                  )
                  as BuiltList<AnalyticsDetailItem>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        case r'sums':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltMap, [
                      FullType(String),
                      FullType(String),
                    ]),
                  )
                  as BuiltMap<String, String>;
          result.sums.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDetailResponseBuilder();
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
