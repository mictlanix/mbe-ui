//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/customer_payment_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_customer_payment_response.g.dart';

/// ListResponseCustomerPaymentResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCustomerPaymentResponse
    implements
        Built<
          ListResponseCustomerPaymentResponse,
          ListResponseCustomerPaymentResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CustomerPaymentResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCustomerPaymentResponse._();

  factory ListResponseCustomerPaymentResponse([
    void updates(ListResponseCustomerPaymentResponseBuilder b),
  ]) = _$ListResponseCustomerPaymentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCustomerPaymentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCustomerPaymentResponse> get serializer =>
      _$ListResponseCustomerPaymentResponseSerializer();
}

class _$ListResponseCustomerPaymentResponseSerializer
    implements PrimitiveSerializer<ListResponseCustomerPaymentResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseCustomerPaymentResponse,
    _$ListResponseCustomerPaymentResponse,
  ];

  @override
  final String wireName = r'ListResponseCustomerPaymentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCustomerPaymentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(CustomerPaymentResponse),
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
    ListResponseCustomerPaymentResponse object, {
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
    required ListResponseCustomerPaymentResponseBuilder result,
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
                      FullType(CustomerPaymentResponse),
                    ]),
                  )
                  as BuiltList<CustomerPaymentResponse>;
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
  ListResponseCustomerPaymentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCustomerPaymentResponseBuilder();
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
