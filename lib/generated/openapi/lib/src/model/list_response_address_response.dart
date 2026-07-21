//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/address_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_address_response.g.dart';

/// ListResponseAddressResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseAddressResponse
    implements
        Built<ListResponseAddressResponse, ListResponseAddressResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AddressResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseAddressResponse._();

  factory ListResponseAddressResponse([
    void updates(ListResponseAddressResponseBuilder b),
  ]) = _$ListResponseAddressResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseAddressResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseAddressResponse> get serializer =>
      _$ListResponseAddressResponseSerializer();
}

class _$ListResponseAddressResponseSerializer
    implements PrimitiveSerializer<ListResponseAddressResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseAddressResponse,
    _$ListResponseAddressResponse,
  ];

  @override
  final String wireName = r'ListResponseAddressResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseAddressResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AddressResponse)]),
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
    ListResponseAddressResponse object, {
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
    required ListResponseAddressResponseBuilder result,
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
                      FullType(AddressResponse),
                    ]),
                  )
                  as BuiltList<AddressResponse>;
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
  ListResponseAddressResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseAddressResponseBuilder();
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
