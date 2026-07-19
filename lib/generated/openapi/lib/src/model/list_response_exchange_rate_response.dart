//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/exchange_rate_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_exchange_rate_response.g.dart';

/// ListResponseExchangeRateResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseExchangeRateResponse
    implements
        Built<
          ListResponseExchangeRateResponse,
          ListResponseExchangeRateResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<ExchangeRateResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseExchangeRateResponse._();

  factory ListResponseExchangeRateResponse([
    void updates(ListResponseExchangeRateResponseBuilder b),
  ]) = _$ListResponseExchangeRateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseExchangeRateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseExchangeRateResponse> get serializer =>
      _$ListResponseExchangeRateResponseSerializer();
}

class _$ListResponseExchangeRateResponseSerializer
    implements PrimitiveSerializer<ListResponseExchangeRateResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseExchangeRateResponse,
    _$ListResponseExchangeRateResponse,
  ];

  @override
  final String wireName = r'ListResponseExchangeRateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseExchangeRateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(ExchangeRateResponse),
      ]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListResponseExchangeRateResponse object, {
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
    required ListResponseExchangeRateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ExchangeRateResponse),
                    ]),
                  )
                  as BuiltList<ExchangeRateResponse>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListResponseExchangeRateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseExchangeRateResponseBuilder();
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
