//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_method_option_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_payment_method_option_response.g.dart';

/// ListResponsePaymentMethodOptionResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponsePaymentMethodOptionResponse
    implements
        Built<
          ListResponsePaymentMethodOptionResponse,
          ListResponsePaymentMethodOptionResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<PaymentMethodOptionResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponsePaymentMethodOptionResponse._();

  factory ListResponsePaymentMethodOptionResponse([
    void updates(ListResponsePaymentMethodOptionResponseBuilder b),
  ]) = _$ListResponsePaymentMethodOptionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponsePaymentMethodOptionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponsePaymentMethodOptionResponse> get serializer =>
      _$ListResponsePaymentMethodOptionResponseSerializer();
}

class _$ListResponsePaymentMethodOptionResponseSerializer
    implements PrimitiveSerializer<ListResponsePaymentMethodOptionResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponsePaymentMethodOptionResponse,
    _$ListResponsePaymentMethodOptionResponse,
  ];

  @override
  final String wireName = r'ListResponsePaymentMethodOptionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponsePaymentMethodOptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(PaymentMethodOptionResponse),
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
    ListResponsePaymentMethodOptionResponse object, {
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
    required ListResponsePaymentMethodOptionResponseBuilder result,
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
                      FullType(PaymentMethodOptionResponse),
                    ]),
                  )
                  as BuiltList<PaymentMethodOptionResponse>;
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
  ListResponsePaymentMethodOptionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponsePaymentMethodOptionResponseBuilder();
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
