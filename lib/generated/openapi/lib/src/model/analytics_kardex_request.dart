//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_kardex_request.g.dart';

/// One product's ledger in one warehouse, any range from the stock history start, paged.
///
/// Properties:
/// * [product]
/// * [warehouse]
/// * [start]
/// * [end]
/// * [skip]
/// * [limit]
@BuiltValue()
abstract class AnalyticsKardexRequest
    implements Built<AnalyticsKardexRequest, AnalyticsKardexRequestBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  @BuiltValueField(wireName: r'skip')
  int? get skip;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  AnalyticsKardexRequest._();

  factory AnalyticsKardexRequest([
    void updates(AnalyticsKardexRequestBuilder b),
  ]) = _$AnalyticsKardexRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsKardexRequestBuilder b) => b
    ..skip = 0
    ..limit = 100;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsKardexRequest> get serializer =>
      _$AnalyticsKardexRequestSerializer();
}

class _$AnalyticsKardexRequestSerializer
    implements PrimitiveSerializer<AnalyticsKardexRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsKardexRequest,
    _$AnalyticsKardexRequest,
  ];

  @override
  final String wireName = r'AnalyticsKardexRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsKardexRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
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
    if (object.skip != null) {
      yield r'skip';
      yield serializers.serialize(
        object.skip,
        specifiedType: const FullType(int),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsKardexRequest object, {
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
    required AnalyticsKardexRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
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
        case r'skip':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.skip = valueDes;
          break;
        case r'limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsKardexRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsKardexRequestBuilder();
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
