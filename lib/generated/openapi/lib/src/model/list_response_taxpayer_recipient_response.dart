//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/taxpayer_recipient_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_taxpayer_recipient_response.g.dart';

/// ListResponseTaxpayerRecipientResponse
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseTaxpayerRecipientResponse implements Built<ListResponseTaxpayerRecipientResponse, ListResponseTaxpayerRecipientResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<TaxpayerRecipientResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseTaxpayerRecipientResponse._();

  factory ListResponseTaxpayerRecipientResponse([void updates(ListResponseTaxpayerRecipientResponseBuilder b)]) = _$ListResponseTaxpayerRecipientResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseTaxpayerRecipientResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseTaxpayerRecipientResponse> get serializer => _$ListResponseTaxpayerRecipientResponseSerializer();
}

class _$ListResponseTaxpayerRecipientResponseSerializer implements PrimitiveSerializer<ListResponseTaxpayerRecipientResponse> {
  @override
  final Iterable<Type> types = const [ListResponseTaxpayerRecipientResponse, _$ListResponseTaxpayerRecipientResponse];

  @override
  final String wireName = r'ListResponseTaxpayerRecipientResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseTaxpayerRecipientResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(TaxpayerRecipientResponse)]),
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
    ListResponseTaxpayerRecipientResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseTaxpayerRecipientResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TaxpayerRecipientResponse)]),
          ) as BuiltList<TaxpayerRecipientResponse>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  ListResponseTaxpayerRecipientResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseTaxpayerRecipientResponseBuilder();
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

