//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_list_response.g.dart';

/// PriceListResponse
///
/// Properties:
/// * [priceListId] 
/// * [name] 
/// * [highProfitMargin] 
/// * [lowProfitMargin] 
@BuiltValue()
abstract class PriceListResponse implements Built<PriceListResponse, PriceListResponseBuilder> {
  @BuiltValueField(wireName: r'price_list_id')
  int get priceListId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'high_profit_margin')
  String get highProfitMargin;

  @BuiltValueField(wireName: r'low_profit_margin')
  String get lowProfitMargin;

  PriceListResponse._();

  factory PriceListResponse([void updates(PriceListResponseBuilder b)]) = _$PriceListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceListResponse> get serializer => _$PriceListResponseSerializer();
}

class _$PriceListResponseSerializer implements PrimitiveSerializer<PriceListResponse> {
  @override
  final Iterable<Type> types = const [PriceListResponse, _$PriceListResponse];

  @override
  final String wireName = r'PriceListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'price_list_id';
    yield serializers.serialize(
      object.priceListId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'high_profit_margin';
    yield serializers.serialize(
      object.highProfitMargin,
      specifiedType: const FullType(String),
    );
    yield r'low_profit_margin';
    yield serializers.serialize(
      object.lowProfitMargin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PriceListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PriceListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'price_list_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceListId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'high_profit_margin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.highProfitMargin = valueDes;
          break;
        case r'low_profit_margin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lowProfitMargin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PriceListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceListResponseBuilder();
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

